import Foundation

enum PuzzleType: String, Sendable {
    case checkmate
    case tactical
}

/// Chess puzzle representation used by the puzzle mode.
struct ChessPuzzle: Equatable, Sendable {
    let initialState: GameState
    let userMoves: [Move]
    let aiMoves: [Move]
    let userColor: PieceColor
    let puzzleType: PuzzleType
    let puzzleRating: Int
    let targetMaterialGain: Int?

    // Backwards-compatible aliases
    var solutionMoves: [Move] { userMoves }
    var opponentMoves: [Move] { aiMoves }
}

struct ChessPuzzleGenerator {
    static let maxStep = 5

    enum Goal {
        case checkmate
        case material(threshold: Int)
    }

    /// Generate a puzzle. Pass a puzzleRating to influence candidate generation.
    /// If preferredType is provided the generator will attempt to produce that type.
    static func generate(puzzleRating: Int = 1200, preferredType: PuzzleType? = nil) -> ChessPuzzle {
        for _ in 0..<200 {
            if Task.isCancelled { break }
            let state = randomPosition()

            // Basic validity checks
            guard !state.status.isGameOver else { continue }
            guard state.findKing(.white) != nil, state.findKing(.black) != nil else { continue }

            // Avoid extremely lopsided positions
            let material = materialAdvantage(state, for: state.currentTurn)
            guard abs(material) < 1_000 else { continue }

            let userColor = state.currentTurn

            // Prefer tactical over checkmate for speed
            if let tuple = buildSolution(state, for: userColor, rating: puzzleRating, desiredType: .tactical) {
                return ChessPuzzle(
                    initialState: state,
                    userMoves: tuple.userMoves,
                    aiMoves: tuple.aiMoves,
                    userColor: userColor,
                    puzzleType: tuple.puzzleType,
                    puzzleRating: puzzleRating,
                    targetMaterialGain: tuple.targetMaterialGain
                )
            }
        }

        // Fallback empty puzzle
        return ChessPuzzle(
            initialState: GameState(),
            userMoves: [],
            aiMoves: [],
            userColor: .white,
            puzzleType: .tactical,
            puzzleRating: puzzleRating,
            targetMaterialGain: nil
        )
    }

    static func retryPuzzle(_ puzzle: ChessPuzzle) -> ChessPuzzle {
        generate(puzzleRating: puzzle.puzzleRating, preferredType: puzzle.puzzleType)
    }

    private static func randomPosition() -> GameState {
        var state = GameState()

        let moveCount = Int.random(in: 5...12)

        for _ in 0..<moveCount {
            if state.status.isGameOver { break }

            let moves = state.allLegalMoves()
            guard !moves.isEmpty else { break }

            if let move = moves.randomElement() {
                state.applyMove(move)
            }
        }

        return state
    }

    /// Attempt to build a full solution line (user moves + stored AI replies).
    /// Returns user/ai moves, the resolved puzzle type and the material target (if any).
    private static func buildSolution(
        _ state: GameState,
        for userColor: PieceColor,
        rating: Int,
        desiredType: PuzzleType
    ) -> (userMoves: [Move], aiMoves: [Move], puzzleType: PuzzleType, targetMaterialGain: Int?)? {

        var userMoves: [Move] = []
        userMoves.reserveCapacity(maxStep)
        var aiMoves: [Move] = []
        aiMoves.reserveCapacity(maxStep)

        var currentState = state
        let aiColor = userColor.opponent
        let initialMaterial = materialAdvantage(state, for: userColor)

        // Map the provided rating to generation parameters such as search depth
        // and candidate move width. The material threshold is kept at the
        // minimum required value (300 centipawns) per product rules.
        let params = generationParameters(for: rating)
        let materialThreshold = params.materialThreshold

        for stepIndex in 0..<maxStep {
            if Task.isCancelled { return nil }

            // Decide goal for this search
            let goal: Goal = desiredType == .checkmate ? .checkmate : .material(threshold: materialThreshold)

            // Limit the search depth per rating and remaining allowed steps
            let depthForThisStep = min(params.searchDepth, 5 - userMoves.count)

            guard let userMove = findWinningMove(
                currentState,
                for: userColor,
                depth: depthForThisStep,
                rating: rating,
                goal: goal,
                candidateWidth: params.candidateWidth
            ) else {
                // If we found at least one move, return what we have
                return userMoves.isEmpty ? nil : (userMoves, aiMoves, .tactical, materialThreshold)
            }

            userMoves.append(userMove)
            currentState.applyMove(userMove)

            // If user delivers mate we are done
            if currentState.status.isCheckmate(winner: userColor) {
                return (userMoves, aiMoves, .checkmate, nil)
            }

            if currentState.status.isGameOver {
                return nil
            }

            // Tactical success: material advantage reached - only return if we have 2+ moves
            let currentMaterial = materialAdvantage(currentState, for: userColor)
            if userMoves.count >= 2, currentMaterial >= materialThreshold, currentMaterial > initialMaterial {
                return (userMoves, aiMoves, .tactical, materialThreshold)
            }

            // Choose a deterministic AI reply using a strong engine setting to avoid randomness
            let aiCandidateMoves = currentState.allLegalMoves(for: aiColor)
            guard !aiCandidateMoves.isEmpty else {
                // If no AI moves but we have user moves, return what we have
                return userMoves.isEmpty ? nil : (userMoves, aiMoves, .tactical, materialThreshold)
            }

            guard let aiMove = ChessAIEngine.selectAIMove(
                from: aiCandidateMoves,
                in: currentState,
                rating: 1000,
                for: aiColor
            ) else {
                return userMoves.isEmpty ? nil : (userMoves, aiMoves, .tactical, materialThreshold)
            }

            aiMoves.append(aiMove)
            currentState.applyMove(aiMove)

            if currentState.status.isCheckmate(winner: aiColor) {
                return nil
            }

            if currentState.status.isGameOver {
                return nil
            }
        }

        // If we have moves, return them
        return userMoves.isEmpty ? nil : (userMoves, aiMoves, .tactical, materialThreshold)
    }

    private static func findWinningMove(
        _ state: GameState,
        for side: PieceColor,
        depth: Int,
        rating: Int,
        goal: Goal
    , candidateWidth: Int
    ) -> Move? {

        if Task.isCancelled { return nil }
        let moves = state.allLegalMoves(for: side)
        guard !moves.isEmpty else { return nil }

        // Prefer captures and promotions
        let candidateMoves = moves.sorted {
            (lhs: Move, rhs: Move) in
            (lhs.captured?.value ?? 0) > (rhs.captured?.value ?? 0)
        }

        // Narrow candidate width based on generation parameters to control
        // the branching factor of the generation search.
        let searchMoves = candidateMoves.prefix(candidateWidth)

        for move in searchMoves {
            if Task.isCancelled { return nil }
            var after = state
            after.applyMove(move)

            // Goal: checkmate
            if case .checkmate = goal, after.status.isCheckmate(winner: side) {
                return move
            }

            // Goal: material
            if case .material(let threshold) = goal {
                let material = materialAdvantage(after, for: side)
                if material >= threshold {
                    // quick safety check: ensure opponent cannot immediately refute and drop material below threshold
                    let opponentMoves = after.allLegalMoves(for: side.opponent)
                    if !opponentMoves.isEmpty {
                        var safe = true
                        for opponentMove in opponentMoves.prefix(3) {
                            var replyState = after
                            replyState.applyMove(opponentMove)
                            if materialAdvantage(replyState, for: side) < threshold {
                                safe = false
                                break
                            }
                        }
                        if safe { return move }
                    }
                }
            }

            if after.status.isGameOver { continue }

            guard depth > 1 else { continue }

            // Let the strong engine pick a reply (deterministic at high rating)
            let aiColor = side.opponent
            let aiMoves = after.allLegalMoves(for: aiColor)
            guard !aiMoves.isEmpty else { continue }

            guard let aiMove = ChessAIEngine.selectAIMove(from: aiMoves, in: after, rating: 1000, for: aiColor) else { continue }

            var afterAI = after
            afterAI.applyMove(aiMove)

            if afterAI.status.isGameOver { continue }

            // Recurse trying to achieve the same goal
            if findWinningMove(afterAI, for: side, depth: depth - 1, rating: rating, goal: goal, candidateWidth: candidateWidth) != nil {
                return move
            }
        }

        return nil
    }

    static func materialAdvantage(_ state: GameState, for side: PieceColor) -> Int {
        var score = 0
        let board = state.board
        for row in 0..<8 {
            for col in 0..<8 {
                guard let piece = board[row][col] else { continue }
                score += (piece.color == side ? 1 : -1) * piece.value * 100
            }
        }
        return score
    }

    private struct GenerationParams {
        let searchDepth: Int
        let candidateWidth: Int
        let materialThreshold: Int
    }

    /// Map an Elo-like rating to generation parameters. Kept simple and
    /// deterministic: higher ratings permit deeper search and wider candidate
    /// move consideration.
    private static func generationParameters(for rating: Int) -> GenerationParams {
        let r = ChessRatingProfile.clamp(rating)
        switch r {
        case ..<700:
            return GenerationParams(searchDepth: 1, candidateWidth: 3, materialThreshold: 300)
        case 700..<1100:
            return GenerationParams(searchDepth: 1, candidateWidth: 4, materialThreshold: 300)
        case 1100..<1500:
            return GenerationParams(searchDepth: 2, candidateWidth: 5, materialThreshold: 400)
        case 1500..<1900:
            return GenerationParams(searchDepth: 2, candidateWidth: 6, materialThreshold: 500)
        default:
            return GenerationParams(searchDepth: 2, candidateWidth: 8, materialThreshold: 600)
        }
    }
}

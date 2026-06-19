import Foundation

enum ChessAIEngine {
    nonisolated static func selectAIMove(from moves: [Move], in game: GameState, rating: Int, for color: PieceColor) -> Move? {
        guard !moves.isEmpty else { return nil }

        let profile = ChessAIProfile(rating: rating)
        let orderedMoves = moves.sorted { lhs, rhs in
            fastMoveOrderScore(for: lhs) > fastMoveOrderScore(for: rhs)
        }
        var scoredMoves: [(Move, Int)] = []

        if profile.searchDepth > 3 {
            let quickMoves = orderedMoves.prefix(8)
            for move in quickMoves {
                var newGame = game
                newGame.applyMove(move)
                var score = heuristicScore(for: move, in: game)
                score += -negamax(
                    game: newGame,
                    depth: min(profile.searchDepth - 2, 2),
                    alpha: -100_000,
                    beta: 100_000,
                    maximizingColor: color
                )
                scoredMoves.append((move, score))
            }
            scoredMoves.sort { $0.1 > $1.1 }
            let candidates = scoredMoves.prefix(profile.candidateCount + 2)
            scoredMoves = candidates.map { ($0.0, 0) }
            for i in scoredMoves.indices {
                var newGame = game
                newGame.applyMove(scoredMoves[i].0)
                var score = heuristicScore(for: scoredMoves[i].0, in: game)
                if !newGame.status.isGameOver {
                    score += -negamax(
                        game: newGame,
                        depth: profile.searchDepth - 1,
                        alpha: -100_000,
                        beta: 100_000,
                        maximizingColor: color
                    )
                } else {
                    score += evaluateBoard(newGame, for: color)
                }
                scoredMoves[i].1 = score
            }
        } else {
            for move in orderedMoves {
                var newGame = game
                newGame.applyMove(move)
                var score = heuristicScore(for: move, in: game)
                if profile.searchDepth > 1, !newGame.status.isGameOver {
                    score += -negamax(
                        game: newGame,
                        depth: profile.searchDepth - 1,
                        alpha: -100_000,
                        beta: 100_000,
                        maximizingColor: color
                    )
                } else {
                    score += evaluateBoard(newGame, for: color)
                }
                scoredMoves.append((move, score))
            }
        }

        scoredMoves.sort { $0.1 > $1.1 }
        let candidateCount = min(profile.candidateCount, scoredMoves.count)
        let candidateMoves = Array(scoredMoves.prefix(candidateCount))

        if profile.randomness == 0 {
            return candidateMoves.first?.0
        }

        let randomizedMoves = candidateMoves.map { move, score in
            (move, score + Int.random(in: -profile.randomness...profile.randomness))
        }

        return randomizedMoves.max(by: { $0.1 < $1.1 })?.0
    }

    private nonisolated static func fastMoveOrderScore(for move: Move) -> Int {
        var score = 0
        if let captured = move.captured {
            score += captured.value * 100
        }
        if move.promotion != nil {
            score += 900
        }
        if move.isCastling {
            score += 50
        }
        return score
    }

    private nonisolated static func negamax(
        game: GameState,
        depth: Int,
        alpha: Int,
        beta: Int,
        maximizingColor: PieceColor
    ) -> Int {
        if depth == 0 || game.status.isGameOver {
            return terminalOrEvaluationScore(for: game, maximizingColor: maximizingColor)
        }

        let moves = game.allLegalMoves(for: game.currentTurn)
        if moves.isEmpty {
            var terminalState = game
            terminalState.updateStatus()
            return terminalOrEvaluationScore(for: terminalState, maximizingColor: maximizingColor)
        }

        var bestScore = -100_000
        var alpha = alpha
        let orderedMoves = moves.sorted { lhs, rhs in
            fastMoveOrderScore(for: lhs) > fastMoveOrderScore(for: rhs)
        }

        let maxWidth: Int
        if depth >= 4 {
            maxWidth = 4
        } else if depth >= 3 {
            maxWidth = 6
        } else if depth >= 2 {
            maxWidth = 10
        } else {
            maxWidth = orderedMoves.count
        }
        let limitedMoves = orderedMoves.prefix(maxWidth)

        for move in limitedMoves {
            var nextGame = game
            nextGame.applyMove(move)
            let score = -negamax(
                game: nextGame,
                depth: depth - 1,
                alpha: -beta,
                beta: -alpha,
                maximizingColor: maximizingColor
            )
            bestScore = max(bestScore, score)
            alpha = max(alpha, score)
            if alpha >= beta {
                break
            }
        }

        return bestScore
    }

    private nonisolated static func terminalOrEvaluationScore(
        for game: GameState,
        maximizingColor: PieceColor
    ) -> Int {
        switch game.status {
        case .checkmate(let winner):
            return winner == maximizingColor ? 50_000 : -50_000
        case .stalemate:
            return 0
        case .playing, .check:
            return evaluateBoard(game, for: maximizingColor)
        }
    }

    private nonisolated static func evaluateBoard(_ game: GameState, for maximizingColor: PieceColor) -> Int {
        var materialScore = 0
        var centerScore = 0

        for row in 0..<8 {
            for col in 0..<8 {
                guard let piece = game.board[row][col] else { continue }
                let sign = piece.color == maximizingColor ? 1 : -1
                materialScore += piece.value * 100 * sign

                let centerDist = abs(Double(row) - 3.5) + abs(Double(col) - 3.5)
                let activityBonus = Int(max(0, 4.0 - centerDist) * 8.0)
                centerScore += activityBonus * sign
            }
        }

        let mobilityBase = game.currentTurn
        let mobilityScore = game.allLegalMoves(for: mobilityBase).count * (mobilityBase == maximizingColor ? 4 : -4)
        let checkBonus: Int
        if case .check = game.status {
            checkBonus = game.currentTurn == maximizingColor ? -30 : 30
        } else {
            checkBonus = 0
        }

        return materialScore + centerScore + mobilityScore + checkBonus
    }

    private nonisolated static func heuristicScore(for move: Move, in game: GameState) -> Int {
        var score = 0

        if let captured = move.captured {
            let movingValue = game.piece(at: move.from)?.value ?? 0
            score += (captured.value * 120) - (movingValue * 10)
        }

        if let promotion = move.promotion {
            score += ChessPiece(type: promotion, color: .black).value * 100
        }

        let centerDist = abs(Double(move.to.row) - 3.5) + abs(Double(move.to.col) - 3.5)
        score += Int(max(0, 4.0 - centerDist) * 10.0)

        if move.isCastling {
            score += 40
        }

        var newGame = game
        newGame.applyMove(move)
        if case .check = newGame.status {
            score += 60
        }
        if case .checkmate = newGame.status {
            score += 10_000
        }

        return score
    }
}

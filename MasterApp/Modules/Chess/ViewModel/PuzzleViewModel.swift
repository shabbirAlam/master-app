import Foundation
import Observation

@MainActor
@Observable
final class PuzzleViewModel {
    private let repository: PuzzleRepository?
    private(set) var gameState: GameState
    private(set) var currentPuzzle: ChessPuzzle
    private(set) var currentStep: Int = 0
    private(set) var selectedPosition: Position?
    private(set) var validMoves: [Position] = []
    private(set) var puzzleCompleted: Bool = false
    private(set) var puzzleFailed: Bool = false
    private(set) var errorMessage: String?
    private(set) var isLoading = false
    var showHints = true
    private(set) var userRating: Int = 800
    private(set) var puzzleRating: Int
    private(set) var availablePuzzles: [ChessPuzzle] = []

    var totalSteps: Int { currentPuzzle.totalSteps }
    var isLastStep: Bool { currentStep >= currentPuzzle.expectedMoves.count - 1 }

    init(repository: PuzzleRepository, userRating: Int = 800) {
        self.repository = repository
        self.userRating = userRating
        let placeholder = ChessPuzzle(
            id: "",
            title: "Loading...",
            rating: 0,
            fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -",
            expectedMoves: [],
            responseMoves: []
        )
        self.currentPuzzle = placeholder
        self.puzzleRating = 0
        self.gameState = GameState(fen: placeholder.fen)!
        Task { await loadInitial() }
    }

    init(puzzle: ChessPuzzle, userRating: Int = 800) {
        self.repository = nil
        self.currentPuzzle = puzzle
        self.puzzleRating = puzzle.rating
        self.userRating = userRating
        guard let state = GameState(fen: puzzle.fen) else {
            fatalError("Invalid FEN in puzzle \(puzzle.id)")
        }
        self.gameState = state
    }

    private func loadInitial() async {
        isLoading = true
        let puzzles = (try? repository?.puzzles(near: userRating, range: 200)) ?? []
        availablePuzzles = puzzles
        if let first = puzzles.first {
            applyPuzzle(first)
        } else {
            let fallback = try? repository?.randomPuzzle(excluding: nil, near: 1200, range: 800) ?? nil
            if let fallback { applyPuzzle(fallback) }
        }
        isLoading = false
    }

    func selectSquare(at position: Position) {
        guard !puzzleCompleted, !puzzleFailed else {
            selectedPosition = nil
            validMoves = []
            return
        }

        if let selected = selectedPosition {
            let piece = gameState.board[selected.row][selected.col]
            if piece?.color == gameState.currentTurn && position == selected {
                selectedPosition = nil
                validMoves = []
                return
            }
            let legal = gameState.legalMoves(at: selected)
            if legal.contains(where: { $0.to == position }) {
                let fromStr = positionToUCI(selected)
                let toStr = positionToUCI(position)
                let uci = fromStr + toStr
                applyUserMove(uci, from: selected, to: position)
                return
            }
            if gameState.board[position.row][position.col]?.color == gameState.currentTurn {
                selectedPosition = position
                validMoves = gameState.legalMoves(at: position).map(\.to)
                return
            }
            selectedPosition = nil
            validMoves = []
        } else {
            if gameState.board[position.row][position.col]?.color == gameState.currentTurn {
                selectedPosition = position
                validMoves = gameState.legalMoves(at: position).map(\.to)
            }
        }
    }

    private func applyUserMove(_ uci: String, from: Position, to: Position) {
        let expected = currentPuzzle.expectedMoves[currentStep]
        guard uci == expected else {
            let fromNotation = positionToChessNotation(from)
            let toNotation = positionToChessNotation(to)
            errorMessage = "Expected \(expected.prefix(2))-\(expected.suffix(2)), not \(fromNotation)-\(toNotation)"
            puzzleFailed = true
            AppLogger.chessAI.log("Puzzle \(self.currentPuzzle.id) step \(self.currentStep): expected \(expected), got \(uci)", .error)
            return
        }

        guard gameState.applyUCIMove(uci) else {
            errorMessage = "Illegal move"
            puzzleFailed = true
            return
        }

        selectedPosition = nil
        validMoves = []
        errorMessage = nil
        currentStep += 1

        applyResponseMoves()
        guard !puzzleFailed else { return }

        if currentStep >= currentPuzzle.expectedMoves.count {
            puzzleCompleted = true
            AppLogger.chessAI.log("Puzzle \(self.currentPuzzle.id) completed", .info)
        }
    }

    private func applyResponseMoves() {
        let responseIndex = currentStep - 1
        guard responseIndex < currentPuzzle.responseMoves.count else { return }

        let response = currentPuzzle.responseMoves[responseIndex]
        guard gameState.applyUCIMove(response) else {
            AppLogger.chessAI.log("Failed to apply response \(response) in puzzle \(self.currentPuzzle.id)", .error)
            puzzleFailed = true
            return
        }
    }

    private func positionToUCI(_ pos: Position) -> String {
        guard let scalar = UnicodeScalar(97 + pos.col) else { return "" }
        let file = String(scalar)
        let rank = String(8 - pos.row)
        return file + rank
    }

    private func positionToChessNotation(_ pos: Position) -> String {
        positionToUCI(pos)
    }

    func retry() {
        guard let state = GameState(fen: currentPuzzle.fen) else { return }
        gameState = state
        currentStep = 0
        selectedPosition = nil
        validMoves = []
        puzzleCompleted = false
        puzzleFailed = false
        errorMessage = nil
    }

    func nextPuzzle() {
        let remaining = availablePuzzles.filter { $0.id != currentPuzzle.id }
        if let next = remaining.randomElement() {
            applyPuzzle(next)
        } else {
            Task { await loadAndSelectNext() }
        }
    }

    func selectPuzzle(_ puzzle: ChessPuzzle) {
        applyPuzzle(puzzle)
    }

    func reset() {
        retry()
    }

    private func applyPuzzle(_ puzzle: ChessPuzzle) {
        guard let state = GameState(fen: puzzle.fen) else {
            AppLogger.chessAI.log("Invalid FEN for puzzle \(puzzle.id): \(puzzle.fen)", .error)
            return
        }
        currentPuzzle = puzzle
        puzzleRating = puzzle.rating
        gameState = state
        currentStep = 0
        selectedPosition = nil
        validMoves = []
        puzzleCompleted = false
        puzzleFailed = false
        errorMessage = nil
    }

    private func loadAndSelectNext() async {
        let next = try? repository?.randomPuzzle(excluding: currentPuzzle.id, near: userRating, range: 300) ?? nil
        guard let next else { return }
        applyPuzzle(next)
    }
}

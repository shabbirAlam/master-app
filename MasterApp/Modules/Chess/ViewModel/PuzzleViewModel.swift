import Foundation
import Observation

/// Presentation state and gameplay logic for the chess puzzle flow.
@MainActor
@Observable
final class PuzzleViewModel {
    /// Repository used to fetch a random or specific puzzle.
    private let repository: PuzzleRepository?
    /// Rating service used to update player skill after puzzle outcomes.
    private let ratingService: ChessRatingService
    /// Current board position for the active puzzle.
    private(set) var gameState: GameState
    /// Active puzzle metadata.
    private(set) var currentPuzzle: ChessPuzzle
    /// Number of moves already applied by the user in the current puzzle.
    private(set) var currentStep: Int = 0
    /// The square selected by the user, if any.
    private(set) var selectedPosition: Position?
    /// Legal destinations highlighted for the selected piece.
    private(set) var validMoves: [Position] = []
    /// Whether the puzzle has been solved successfully.
    private(set) var puzzleCompleted: Bool = false
    /// Whether the puzzle has failed because of an invalid move or mismatch.
    private(set) var puzzleFailed: Bool = false
    /// User-facing message for puzzle failure or validation issues.
    private(set) var errorMessage: String?
    /// Whether the puzzle is still being loaded from storage.
    private(set) var isLoading = false
    /// Enables or disables move hints while playing the puzzle.
    var showHints = true
    /// Current user rating after all prior puzzle results.
    private(set) var userRating: Int = 800
    /// Rating of the active puzzle.
    private(set) var puzzleRating: Int
    /// Total moves expected for the puzzle sequence.
    var totalSteps: Int { currentPuzzle.totalSteps }
    /// Whether the current step is the final expected move in the puzzle.
    var isLastStep: Bool { currentStep >= currentPuzzle.expectedMoves.count - 1 }

    /// Creates a view model that loads a random puzzle from the repository.
    /// - Parameters:
    ///   - repository: Puzzle source used to fetch challenge data.
    ///   - ratingService: Service used to update Elo ratings.
    ///   - userRating: The user's current rating.
    init(repository: PuzzleRepository, ratingService: ChessRatingService, userRating: Int = 800) {
        self.repository = repository
        self.ratingService = ratingService
        self.userRating = userRating
        let placeholder = ChessPuzzle(
            id: "",
            title: "Loading...",
            rating: 0,
            fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -",
            premove: nil,
            expectedMoves: [],
            responseMoves: []
        )
        self.currentPuzzle = placeholder
        self.puzzleRating = 0
        self.gameState = GameState(fen: placeholder.fen)!
        Task { await loadInitial() }
    }

    /// Creates a view model around a known puzzle instance for preview or test scenarios.
    /// - Parameters:
    ///   - puzzle: The specific puzzle to render.
    ///   - ratingService: Service used to record rating updates.
    ///   - userRating: The current user rating.
    init(puzzle: ChessPuzzle, ratingService: ChessRatingService = ChessRatingServiceImpl(store: InMemoryChessRatingStore()), userRating: Int = 800) {
        self.repository = nil
        self.ratingService = ratingService
        self.currentPuzzle = puzzle
        self.puzzleRating = puzzle.rating
        self.userRating = userRating
        guard var state = GameState(fen: puzzle.fen) else {
            fatalError("Invalid FEN in puzzle \(puzzle.id)")
        }
        if let premove = puzzle.premove {
            guard state.applyUCIMove(premove) else {
                fatalError("Invalid pre-move \(premove) for puzzle \(puzzle.id)")
            }
        }
        self.gameState = state
    }

    /// Loads the first random puzzle near the player's current rating.
    private func loadInitial() async {
        isLoading = true
        if let puzzle = try? repository?.randomPuzzle(excluding: nil, near: userRating, range: 100) {
            applyPuzzle(puzzle)
        }
        isLoading = false
    }

    /// Handles a square tap by selecting a piece or applying a legal move.
    /// - Parameter position: The square tapped by the user.
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

    private var hasAppliedRatingUpdate = false

    /// Applies the Elo update associated with a puzzle result once.
    /// - Parameter outcome: The outcome of the puzzle.
    private func applyRatingUpdate(_ outcome: ChessMatchOutcome) {
        guard !hasAppliedRatingUpdate else { return }
        hasAppliedRatingUpdate = true
        let profile = ratingService.applyMatchOutcome(outcome, opponentRating: puzzleRating)
        userRating = profile.userRating
        AppLogger.viewModel.log("Puzzle rating update: \(outcome) vs \(puzzleRating), new rating: \(userRating)", .info)
    }

    /// Validates the user's move against the expected move sequence and applies it if legal.
    /// - Parameters:
    ///   - uci: The move in UCI format.
    ///   - from: Original selected square.
    ///   - to: Destination square.
    private func applyUserMove(_ uci: String, from: Position, to: Position) {
        let expected = currentPuzzle.expectedMoves[currentStep]
        guard uci == expected else {
            let fromNotation = positionToChessNotation(from)
            let toNotation = positionToChessNotation(to)
            errorMessage = "Expected \(expected.prefix(2))-\(expected.suffix(2)), not \(fromNotation)-\(toNotation)"
            puzzleFailed = true
            applyRatingUpdate(.loss)
            AppLogger.chessAI.log("Puzzle \(self.currentPuzzle.id) step \(self.currentStep): expected \(expected), got \(uci)", .error)
            return
        }

        guard gameState.applyUCIMove(uci) else {
            errorMessage = "Illegal move"
            puzzleFailed = true
            applyRatingUpdate(.loss)
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
            applyRatingUpdate(.win)
            AppLogger.chessAI.log("Puzzle \(self.currentPuzzle.id) completed", .info)
        }
    }

    /// Applies any response move configured for the puzzle after the user makes a valid move.
    private func applyResponseMoves() {
        let responseIndex = currentStep - 1
        guard responseIndex < currentPuzzle.responseMoves.count else { return }

        let response = currentPuzzle.responseMoves[responseIndex]
        guard gameState.applyUCIMove(response) else {
            AppLogger.chessAI.log("Failed to apply response \(response) in puzzle \(self.currentPuzzle.id)", .error)
            puzzleFailed = true
            applyRatingUpdate(.loss)
            return
        }
    }

    /// Converts a board position to UCI notation.
    /// - Parameter pos: The board square.
    /// - Returns: UCI string such as "e2" or "h5".
    private func positionToUCI(_ pos: Position) -> String {
        guard let scalar = UnicodeScalar(97 + pos.col) else { return "" }
        let file = String(scalar)
        let rank = String(8 - pos.row)
        return file + rank
    }

    /// Converts a board position to a compact chess-style notation.
    /// - Parameter pos: The board square.
    /// - Returns: The square notation used in validation errors.
    private func positionToChessNotation(_ pos: Position) -> String {
        positionToUCI(pos)
    }

    /// Loads a specific puzzle by identifier from the repository.
    /// - Parameter id: The puzzle identifier.
    func loadPuzzleById(_ id: String) {
        guard let puzzle = try? repository?.puzzleById(id) else {
            errorMessage = "Puzzle \(id) not found"
            return
        }
        applyPuzzle(puzzle)
    }

    /// Resets the current puzzle to its initial board state.
    func retry() {
        guard var state = GameState(fen: currentPuzzle.fen) else { return }
        if let premove = currentPuzzle.premove {
            guard state.applyUCIMove(premove) else { return }
        }
        gameState = state
        currentStep = 0
        selectedPosition = nil
        validMoves = []
        puzzleCompleted = false
        puzzleFailed = false
        errorMessage = nil
        hasAppliedRatingUpdate = false
    }

    /// Loads a different puzzle near the player's current rating.
    func nextPuzzle() {
        guard let puzzle = try? repository?.randomPuzzle(excluding: currentPuzzle.id, near: userRating, range: 100) else { return }
        applyPuzzle(puzzle)
    }

    /// Resets the active challenge to its initial state.
    func reset() {
        retry()
    }

    /// Applies a puzzle object to the view model and resets all related state.
    /// - Parameter puzzle: The newly selected puzzle.
    private func applyPuzzle(_ puzzle: ChessPuzzle) {
        guard var state = GameState(fen: puzzle.fen) else {
            AppLogger.chessAI.log("Invalid FEN for puzzle \(puzzle.id): \(puzzle.fen)", .error)
            return
        }
        if let premove = puzzle.premove {
            guard state.applyUCIMove(premove) else {
                AppLogger.chessAI.log("Invalid pre-move \(premove) for puzzle \(puzzle.id)", .error)
                return
            }
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
        hasAppliedRatingUpdate = false
    }
}

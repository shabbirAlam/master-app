import Foundation
import Observation

@MainActor
@Observable
final class ChessViewModel {
    private(set) var game: GameState
    private(set) var gameMode: GameMode?
    private(set) var userColor: PieceColor = .white
    private(set) var selectedPosition: Position?
    private(set) var validMoves: [Position] = []
    private(set) var statusMessage: String = "Welcome"
    private(set) var userRating: Int
    private(set) var computerRating: Int
    private(set) var ratingChangeMessage: String?
    var showPromotionDialog = false
    private(set) var promotionMoves: [Move] = []
    private(set) var isAIThinking = false
    private(set) var userLastMoveTime: Double?
    private(set) var computerLastMoveTime: Double?
    var undoEnabled = false
    private(set) var puzzleState: PuzzleState = .inactive
    private(set) var puzzleStepIndex = 0
    private(set) var currentPuzzle: ChessPuzzle?
    private(set) var hintPosition: Position?
    private(set) var hintDestination: Position?
    private(set) var hintLevel: Int = 0 // 0 = none, 1 = source, 2 = dest, 3 = full move
    private(set) var isGeneratingPuzzle = false

    enum PuzzleState: Equatable {
        case inactive
        case playing
        case success
        case failure
    }

    private let ratingService: ChessRatingService
    private var aiTask: Task<Void, Never>?
    private var puzzleTask: Task<Void, Never>?
    private var hasAppliedRatingUpdate = false
    private var turnStartTime: Date

    private func movesMatch(_ a: Move, _ b: Move) -> Bool {
        a.from == b.from && a.to == b.to && a.promotion == b.promotion
    }

    init(
        ratingService: ChessRatingService = ChessRatingServiceImpl(
            store: InMemoryChessRatingStore()
        )
    ) {
        self.ratingService = ratingService
        let profile = ratingService.loadProfile()
        self.game = GameState()
        self.userRating = profile.userRating
        self.computerRating = profile.computerRating
        self.turnStartTime = Date()
        self.statusMessage = "Select game mode to start"
    }

    nonisolated deinit {
        Task { @MainActor [weak self] in
            self?.aiTask?.cancel()
        }
    }

    func setGameMode(_ mode: GameMode, with color: PieceColor = .white) {
        userColor = color
        gameMode = mode
        game = GameState()
        selectedPosition = nil
        validMoves = []
        ratingChangeMessage = nil
        hasAppliedRatingUpdate = false
        userLastMoveTime = nil
        computerLastMoveTime = nil
        turnStartTime = Date()
        statusMessage = "\(game.currentTurn.rawValue.capitalized)'s turn"
        if case .vsComputer = mode {
            AppLogger.viewModel.log("Game started in vsComputer mode", .info)
            if game.currentTurn != userColor {
                triggerAIMove()
            }
        } else {
            AppLogger.viewModel.log("Game started in twoPlayer mode", .info)
        }
    }

    func selectSquare(at position: Position) {
        guard let mode = gameMode else { return }
        guard !game.status.isGameOver else { return }
        if mode != .twoPlayer, game.currentTurn != userColor { return }
        guard !isAIThinking else { return }

        if selectedPosition == position {
            selectedPosition = nil
            validMoves = []
            return
        }

        if let from = selectedPosition, validMoves.contains(position) {
            let moves = game.legalMoves(at: from).filter { $0.to == position }
            if moves.isEmpty { return }

            if moves.count == 1 {
                executeMove(moves[0])
            } else {
                promotionMoves = moves
                showPromotionDialog = true
            }
            return
        }

        if let piece = game.piece(at: position), piece.color == game.currentTurn {
            selectedPosition = position
            validMoves = game.legalMoves(at: position).map(\.to)
            return
        }

        selectedPosition = nil
        validMoves = []
    }

    func selectPromotion(_ type: PieceType) {
        guard let move = promotionMoves.first(where: { $0.promotion == type }) else { return }
        showPromotionDialog = false
        promotionMoves = []
        executeMove(move)
    }

    private func executeMove(_ move: Move) {
        userLastMoveTime = Date().timeIntervalSince(turnStartTime)
        turnStartTime = Date()

        game.applyMove(move)
        selectedPosition = nil
        hintPosition = nil
        validMoves = []

        if game.status.isGameOver {
            if case .puzzle = gameMode {
                if game.status.isCheckmate(winner: userColor) {
                    puzzleState = .success
                    statusMessage = "Puzzle solved! Checkmate!"
                } else {
                    puzzleState = .failure
                    statusMessage = game.status.message
                }
            } else {
                finalizeCompletedGameIfNeeded()
            }
            AppLogger.viewModel.log("Game over: \(statusMessage)", .notice)
            return
        }

        if case .puzzle = gameMode {
            guard let puzzle = currentPuzzle else { return }

            guard puzzleStepIndex < puzzle.userMoves.count,
                  movesMatch(move, puzzle.userMoves[puzzleStepIndex]) else {
                puzzleState = .failure
                statusMessage = "Wrong move! Try again."
                return
            }
            puzzleStepIndex += 1

            if game.status.isCheckmate(winner: userColor) ||
               ChessPuzzleGenerator.materialAdvantage(game, for: userColor) >= 300 {
                puzzleState = .success
                statusMessage = "Puzzle solved!"
                return
            }

            if puzzleStepIndex >= puzzle.userMoves.count {
                puzzleState = .failure
                statusMessage = "Puzzle failed."
                return
            }

            if puzzleStepIndex - 1 < puzzle.aiMoves.count {
                let aiMove = puzzle.aiMoves[puzzleStepIndex - 1]
                game.applyMove(aiMove)

                if game.status.isGameOver {
                    if game.status.isCheckmate(winner: userColor) {
                        puzzleState = .success
                        statusMessage = "Puzzle solved! Checkmate!"
                    } else {
                        puzzleState = .failure
                        statusMessage = game.status.message
                    }
                    return
                }
            }

            statusMessage = "Puzzle step \(puzzleStepIndex)/\(puzzle.userMoves.count)"
            return
        }

        if case .check = game.status {
            statusMessage = "Check! \(game.currentTurn.rawValue.capitalized)'s turn"
        } else {
            statusMessage = "\(game.currentTurn.rawValue.capitalized)'s turn"
        }

        if gameMode != .twoPlayer, game.currentTurn != userColor {
            triggerAIMove()
        }
    }

    // MARK: - Test Helpers (actions)

    /// Test-only helper to execute a move (wraps private executeMove).
    nonisolated func testExecuteMove(_ move: Move) {
        Task { @MainActor in
            self.executeMove(move)
        }
    }

    func restartGame() {
        if case .puzzle = gameMode {
            retryPuzzle()
            return
        }
        resetBoardState()
        statusMessage = "\(game.currentTurn.rawValue.capitalized)'s turn"
        if gameMode != .twoPlayer, game.currentTurn != userColor {
            triggerAIMove()
        }
    }

    func resetGame() {
        resetBoardState()
        puzzleState = .inactive
        puzzleStepIndex = 0
        currentPuzzle = nil
        statusMessage = "Select game mode to start"
        gameMode = nil
    }

    private func resetBoardState() {
        aiTask?.cancel()
        aiTask = nil
        puzzleTask?.cancel()
        puzzleTask = nil
        isAIThinking = false
        game = GameState()
        selectedPosition = nil
        validMoves = []
        ratingChangeMessage = nil
        hasAppliedRatingUpdate = false
        userLastMoveTime = nil
        computerLastMoveTime = nil
        turnStartTime = Date()
    }

    func updateComputerRating(_ rating: Int) {
        let profile = ratingService.updateComputerRating(rating)
        computerRating = profile.computerRating
    }

    func startPuzzle() {
        guard !isGeneratingPuzzle else { return }
        isGeneratingPuzzle = true
        aiTask?.cancel()
        aiTask = nil
        puzzleTask?.cancel()
        puzzleTask = nil
        currentPuzzle = nil
        game = GameState()
        isAIThinking = false
        gameMode = .puzzle
        puzzleState = .playing
        puzzleStepIndex = 0
        hintPosition = nil
        selectedPosition = nil
        validMoves = []
        statusMessage = "Generating puzzle..."

        puzzleTask = Task.detached(priority: .userInitiated) { [weak self] in
            let puzzle = await MainActor.run {
                ChessPuzzleGenerator.generate()
            }
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.puzzleTask = nil
                self.isGeneratingPuzzle = false
                guard !Task.isCancelled else { return }

                self.currentPuzzle = puzzle
                self.game = puzzle.initialState
                self.userColor = puzzle.userColor
                self.ratingChangeMessage = nil
                self.hasAppliedRatingUpdate = false
                self.userLastMoveTime = nil
                self.computerLastMoveTime = nil
                self.turnStartTime = Date()
                self.statusMessage = "Puzzle step 0/\(puzzle.userMoves.count)"
            }
        }
    }

    func nextPuzzle() {
        startPuzzle()
    }

    func retryPuzzle() {
        guard let puzzle = currentPuzzle else { startPuzzle(); return }
        aiTask?.cancel()
        aiTask = nil
        isAIThinking = false
        game = puzzle.initialState
        selectedPosition = nil
        validMoves = []
        ratingChangeMessage = nil
        hasAppliedRatingUpdate = false
        userLastMoveTime = nil
        computerLastMoveTime = nil
        turnStartTime = Date()
        puzzleState = .playing
        puzzleStepIndex = 0
        hintPosition = nil
        statusMessage = "Puzzle step 0/\(puzzle.userMoves.count)"
    }

    func showHint() {
        guard let puzzle = currentPuzzle, puzzleState == .playing else { return }
        guard puzzleStepIndex < puzzle.userMoves.count else { return }

        // Cycle hint levels 1 -> 2 -> 3. Call again to escalate.
        hintLevel = min(3, hintLevel + 1)
        let move = puzzle.userMoves[puzzleStepIndex]
        switch hintLevel {
        case 1:
            hintPosition = move.from
            hintDestination = nil
        case 2:
            hintPosition = move.from
            hintDestination = move.to
        case 3:
            hintPosition = move.from
            hintDestination = move.to
        default:
            hintPosition = nil
            hintDestination = nil
        }

        AppLogger.viewModel
            .log("hint level: \(hintLevel) from: \(move.from.algebraic) to: \(move.to.algebraic)")
    }

    func undoLastMove() {
        guard undoEnabled, !game.undoStack.isEmpty else { return }
        guard let mode = gameMode else { return }
        aiTask?.cancel()
        aiTask = nil
        isAIThinking = false

        if mode != .twoPlayer {
            if game.undoStack.count >= 2 {
                _ = game.undoLastMove()
            }
        }
        guard game.undoLastMove() else { return }

        ratingChangeMessage = nil
        hasAppliedRatingUpdate = false
        userLastMoveTime = nil
        computerLastMoveTime = nil
        selectedPosition = nil
        validMoves = []
        turnStartTime = Date()

        if game.status.isGameOver {
            statusMessage = game.status.message
        } else if case .check = game.status {
            statusMessage = "Check! \(game.currentTurn.rawValue.capitalized)'s turn"
        } else {
            statusMessage = "\(game.currentTurn.rawValue.capitalized)'s turn"
        }

        if mode != .twoPlayer, game.currentTurn != userColor {
            triggerAIMove()
        }
    }

    private func triggerAIMove() {
        aiTask?.cancel()
        let capturedGame = game
        let capturedRating = computerRating
        let computerColor = userColor.opponent
        isAIThinking = true
        statusMessage = "Computer (\(computerRating)) is thinking..."
        aiTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 50_000_000)
                guard let self else { return }
                try Task.checkCancellation()

                let moves = capturedGame.allLegalMoves(for: computerColor)

                let bestMove = await Task.detached {
                    ChessAIEngine.selectAIMove(from: moves, in: capturedGame, rating: capturedRating, for: computerColor)
                }.value

                try Task.checkCancellation()
                guard let bestMove else {
                    self.isAIThinking = false
                    return
                }
                self.game.applyMove(bestMove)
                self.computerLastMoveTime = Date().timeIntervalSince(self.turnStartTime)
                self.turnStartTime = Date()
                self.selectedPosition = nil
                self.validMoves = []

                if self.game.status.isGameOver {
                    if case .puzzle = self.gameMode {
                        if self.game.status.isCheckmate(winner: self.userColor) {
                            self.puzzleState = .success
                            self.statusMessage = "Puzzle solved! Checkmate!"
                        } else {
                            self.puzzleState = .failure
                            self.statusMessage = self.game.status.message
                        }
                    } else {
                        self.finalizeCompletedGameIfNeeded()
                    }
                } else if case .check = self.game.status {
                    let turn = self.game.currentTurn.rawValue.capitalized
                    if case .puzzle = self.gameMode {
                        let total = self.currentPuzzle?.userMoves.count ?? ChessPuzzleGenerator.maxStep
                        self.statusMessage = "Puzzle step \(self.puzzleStepIndex)/\(total)"
                    } else {
                        self.statusMessage = "Check! \(turn)'s turn"
                    }
                } else if case .puzzle = self.gameMode {
                    let total = self.currentPuzzle?.userMoves.count ?? ChessPuzzleGenerator.maxStep
                    self.statusMessage = "Puzzle step \(self.puzzleStepIndex)/\(total)"
                } else {
                    self.statusMessage = "\(self.game.currentTurn.rawValue.capitalized)'s turn"
                }
                self.isAIThinking = false
            } catch {
                if let self {
                    self.isAIThinking = false
                }
            }
        }
    }

    func backToMenu() {
        resetGame()
    }

    private func finalizeCompletedGameIfNeeded() {
        let baseMessage = game.status.message
        guard case .vsComputer = gameMode, !hasAppliedRatingUpdate else {
            statusMessage = baseMessage
            return
        }

        let outcome: ChessMatchOutcome
        switch game.status {
        case .checkmate(let winner):
            outcome = winner == userColor ? .win : .loss
        case .stalemate:
            outcome = .draw
        case .playing, .check:
            statusMessage = baseMessage
            return
        }

        let previousRating = userRating
        let updatedProfile = ratingService.applyMatchOutcome(outcome)
        userRating = updatedProfile.userRating
        computerRating = updatedProfile.computerRating
        hasAppliedRatingUpdate = true

        let delta = userRating - previousRating
        let deltaPrefix = delta > 0 ? "+" : ""
        let ratingMessage = delta == 0 ? "Rating unchanged" : "Rating \(deltaPrefix)\(delta)"
        ratingChangeMessage = ratingMessage
        statusMessage = "\(baseMessage) \(ratingMessage)"
    }

    // MARK: - Test Helpers

    var userLastMoveTimeString: String? {
        formatMoveTime(userLastMoveTime)
    }

    var computerLastMoveTimeString: String? {
        formatMoveTime(computerLastMoveTime)
    }

    private func formatMoveTime(_ time: Double?) -> String? {
        guard let t = time else { return nil }
        if t < 60 {
            return String(format: "%.1fs", t)
        }
        let minutes = Int(t) / 60
        let seconds = Int(t) % 60
        return "\(minutes)m \(seconds)s"
    }

    func setGameForSnapshot(_ game: GameState) {
        self.game = game
    }

    func setGameModeForSnapshot(_ mode: GameMode) {
        self.gameMode = mode
    }

    func setStatusForSnapshot(_ message: String) {
        self.statusMessage = message
    }

    func setRatingsForSnapshot(userRating: Int, computerRating: Int) {
        self.userRating = userRating
        self.computerRating = computerRating
    }

    /// Test helper: set a full puzzle into the view model for snapshot/testing.
    func setCurrentPuzzleForSnapshot(_ puzzle: ChessPuzzle) {
        self.currentPuzzle = puzzle
        self.game = puzzle.initialState
        self.userColor = puzzle.userColor
        self.gameMode = .puzzle
        self.puzzleState = .playing
        self.puzzleStepIndex = 0
        self.hintLevel = 0
        self.hintPosition = nil
        self.hintDestination = nil
        self.statusMessage = "Puzzle step 0/\(puzzle.userMoves.count)"
    }
}

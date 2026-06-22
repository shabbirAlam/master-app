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
    var undoEnabled = true
    var showHints = true

    private let ratingService: ChessRatingService
    private var aiTask: Task<Void, Never>?
    private var hasAppliedRatingUpdate = false
    private var turnStartTime: Date

    private let chessKitService: ChessKitAIService

    init(
        ratingService: ChessRatingService = ChessRatingServiceImpl(
            store: InMemoryChessRatingStore()
        ),
        chessKitService: ChessKitAIService = ChessKitAIServiceImpl()
    ) {
        self.ratingService = ratingService
        self.chessKitService = chessKitService
        let profile = ratingService.loadProfile()
        self.game = GameState()
        self.userRating = profile.userRating
        self.computerRating = profile.computerRating
        self.turnStartTime = Date()
        self.statusMessage = "Select game mode to start"
        Task { await chessKitService.start() }
    }

    nonisolated deinit {
        Task { @MainActor [weak self] in
            self?.aiTask?.cancel()
            await self?.chessKitService.stop()
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
        validMoves = []

        if game.status.isGameOver {
            finalizeCompletedGameIfNeeded()
            AppLogger.viewModel.log("Game over: \(statusMessage)", .notice)
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
        resetBoardState()
        statusMessage = "\(game.currentTurn.rawValue.capitalized)'s turn"
        if gameMode != .twoPlayer, game.currentTurn != userColor {
            triggerAIMove()
        }
    }

    func resetGame() {
        resetBoardState()
        statusMessage = "Select game mode to start"
        gameMode = nil
    }

    private func resetBoardState() {
        aiTask?.cancel()
        aiTask = nil
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

                let moveTime = moveTime(for: capturedRating)
                let bestMove = try await self.chessKitService.selectMove(
                    from: capturedGame,
                    for: computerColor,
                    moveTime: moveTime
                )

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
                    self.finalizeCompletedGameIfNeeded()
                } else if case .check = self.game.status {
                    let turn = self.game.currentTurn.rawValue.capitalized
                    self.statusMessage = "Check! \(turn)'s turn"
                } else {
                    self.statusMessage = "\(self.game.currentTurn.rawValue.capitalized)'s turn"
                }
                self.isAIThinking = false
            } catch {
                if let self {
                    self.isAIThinking = false
                    self.statusMessage = "Computer error: \(error.localizedDescription)"
                    AppLogger.viewModel.log("AI move failed: \(error.localizedDescription)", .error)
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

    private func moveTime(for rating: Int) -> Int {
        switch rating {
        case ..<700: 300
        case ..<1000: 500
        case ..<1300: 600
        case ..<1600: 700
        case ..<1900: 800
        case ..<2100: 900
        default: 1000
        }
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
}

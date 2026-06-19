import Foundation
import Observation

@MainActor
@Observable
final class ChessViewModel {
    private(set) var game: GameState
    private(set) var gameMode: GameMode?
    private(set) var selectedPosition: Position?
    private(set) var validMoves: [Position] = []
    private(set) var statusMessage: String = "Welcome"
    private(set) var userRating: Int
    private(set) var computerRating: Int
    private(set) var ratingChangeMessage: String?
    var showPromotionDialog = false
    private(set) var promotionMoves: [Move] = []
    private(set) var isAIThinking = false

    private let ratingService: ChessRatingService
    private var aiTask: Task<Void, Never>?
    private var hasAppliedRatingUpdate = false

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
        self.statusMessage = "Select game mode to start"
    }

    nonisolated deinit {
        Task { @MainActor [weak self] in
            self?.aiTask?.cancel()
        }
    }

    func setGameMode(_ mode: GameMode) {
        gameMode = mode
        game = GameState()
        selectedPosition = nil
        validMoves = []
        ratingChangeMessage = nil
        hasAppliedRatingUpdate = false
        statusMessage = "\(game.currentTurn.rawValue.capitalized)'s turn"
        if mode == .vsComputer {
            AppLogger.viewModel.log("Game started in vsComputer mode", .info)
        } else {
            AppLogger.viewModel.log("Game started in twoPlayer mode", .info)
        }
    }

    func selectSquare(at position: Position) {
        guard let mode = gameMode else { return }
        guard !game.status.isGameOver else { return }
        if mode == .vsComputer && game.currentTurn == .black { return }
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

        if gameMode == .vsComputer && game.currentTurn == .black {
            triggerAIMove()
        }
    }

    func resetGame() {
        aiTask?.cancel()
        aiTask = nil
        isAIThinking = false
        game = GameState()
        selectedPosition = nil
        validMoves = []
        ratingChangeMessage = nil
        hasAppliedRatingUpdate = false
        statusMessage = "Select game mode to start"
        gameMode = nil
    }

    func updateComputerRating(_ rating: Int) {
        let profile = ratingService.updateComputerRating(rating)
        computerRating = profile.computerRating
    }

    private func triggerAIMove() {
        aiTask?.cancel()
        isAIThinking = true
        statusMessage = "Computer (\(computerRating)) is thinking..."
        aiTask = Task { [weak self] in
            do {
                let aiRating = self?.computerRating ?? ChessRatingProfile.defaultRating
                try await Task.sleep(nanoseconds: Self.thinkingDelay(for: aiRating))
                guard let self else { return }
                try Task.checkCancellation()

                let moves = self.game.allLegalMoves(for: .black)
                guard let bestMove = GameState.selectAIMove(
                    from: moves,
                    in: self.game,
                    rating: self.computerRating
                ) else { return }
                try Task.checkCancellation()
                self.game.applyMove(bestMove)
                self.selectedPosition = nil
                self.validMoves = []

                if self.game.status.isGameOver {
                    self.finalizeCompletedGameIfNeeded()
                } else if case .check = self.game.status {
                    self.statusMessage = "Check! \(self.game.currentTurn.rawValue.capitalized)'s turn"
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
        guard gameMode == .vsComputer, !hasAppliedRatingUpdate else {
            statusMessage = baseMessage
            return
        }

        let outcome: ChessMatchOutcome
        switch game.status {
        case .checkmate(let winner):
            outcome = winner == .white ? .win : .loss
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

    private static func thinkingDelay(for rating: Int) -> UInt64 {
        switch rating {
        case ..<700:
            250_000_000
        case ..<1200:
            450_000_000
        case ..<1600:
            650_000_000
        default:
            850_000_000
        }
    }

    // MARK: - Test Helpers

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

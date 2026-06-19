import Foundation

protocol ChessRatingService: Sendable {
    func loadProfile() -> ChessRatingProfile
    func updateComputerRating(_ rating: Int) -> ChessRatingProfile
    func applyMatchOutcome(_ outcome: ChessMatchOutcome) -> ChessRatingProfile
}

struct ChessRatingServiceImpl: ChessRatingService {
    private let store: ChessRatingStore
    private let kFactor: Double

    init(
        store: ChessRatingStore,
        kFactor: Double = 24
    ) {
        self.store = store
        self.kFactor = kFactor
    }

    func loadProfile() -> ChessRatingProfile {
        store.loadProfile()
    }

    func updateComputerRating(_ rating: Int) -> ChessRatingProfile {
        var profile = store.loadProfile()
        profile.computerRating = ChessRatingProfile.clamp(rating)
        store.saveProfile(profile)
        return profile
    }

    func applyMatchOutcome(_ outcome: ChessMatchOutcome) -> ChessRatingProfile {
        var profile = store.loadProfile()
        let expectedScore = expectedScore(
            playerRating: profile.userRating,
            opponentRating: profile.computerRating
        )
        let actualScore = score(for: outcome)
        let delta = Int((kFactor * (actualScore - expectedScore)).rounded())
        profile.userRating = ChessRatingProfile.clamp(profile.userRating + delta)
        store.saveProfile(profile)
        return profile
    }

    private func expectedScore(playerRating: Int, opponentRating: Int) -> Double {
        1.0 / (1.0 + pow(10.0, Double(opponentRating - playerRating) / 400.0))
    }

    private func score(for outcome: ChessMatchOutcome) -> Double {
        switch outcome {
        case .win:
            1.0
        case .loss:
            0.0
        case .draw:
            0.5
        }
    }
}

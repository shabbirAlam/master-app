import Foundation

/// Contract for reading and updating a chess player's rating profile.
protocol ChessRatingService: Sendable {
    /// Loads the persisted player profile.
    /// - Returns: The current chess rating profile.
    func loadProfile() -> ChessRatingProfile
    /// Updates the stored computer rating without affecting the player's rating.
    /// - Parameter rating: The new computer rating value.
    /// - Returns: The updated rating profile.
    func updateComputerRating(_ rating: Int) -> ChessRatingProfile
    /// Applies a match result using the stored computer rating.
    /// - Parameter outcome: The match result.
    /// - Returns: The updated profile after recalculating the rating delta.
    func applyMatchOutcome(_ outcome: ChessMatchOutcome) -> ChessRatingProfile
    /// Applies a match result against a specific opponent rating.
    /// - Parameters:
    ///   - outcome: The match result.
    ///   - opponentRating: The opponent's rating.
    /// - Returns: The updated player profile.
    func applyMatchOutcome(_ outcome: ChessMatchOutcome, opponentRating: Int) -> ChessRatingProfile
}

/// Elo-style chess rating service that persists and updates values in a store.
struct ChessRatingServiceImpl: ChessRatingService {
    private let store: ChessRatingStore
    private let kFactor: Double

    /// Creates the rating service with a backing store and rating sensitivity factor.
    /// - Parameters:
    ///   - store: The persistence layer for the ratings.
    ///   - kFactor: The Elo scaling factor used when recalculating skill changes.
    init(
        store: ChessRatingStore,
        kFactor: Double = 24
    ) {
        self.store = store
        self.kFactor = kFactor
        AppLogger.service.log("ChessRatingServiceImpl initialized", .info)
    }

    /// Loads the stored profile from the configured store.
    func loadProfile() -> ChessRatingProfile {
        AppLogger.service.log("Loading chess rating profile", .debug)
        return store.loadProfile()
    }

    /// Updates only the computer rating in the persisted profile.
    /// - Parameter rating: The new computer rating.
    /// - Returns: The updated profile.
    func updateComputerRating(_ rating: Int) -> ChessRatingProfile {
        AppLogger.service.log("Updating computer rating to \(rating)", .info)
        var profile = store.loadProfile()
        profile.computerRating = ChessRatingProfile.clamp(rating)
        store.saveProfile(profile)
        return profile
    }

    /// Applies a cached-profile match outcome and writes the new rating back to storage.
    /// - Parameter outcome: Result of the completed match.
    /// - Returns: Updated rating profile after applying the Elo adjustment.
    func applyMatchOutcome(_ outcome: ChessMatchOutcome) -> ChessRatingProfile {
        AppLogger.service.log("Applying match outcome: \(outcome)", .info)
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

    /// Applies a match result against a specific opponent rating.
    /// - Parameters:
    ///   - outcome: Result of the completed match.
    ///   - opponentRating: Rating used for the expected score calculation.
    /// - Returns: Updated profile after applying the Elo adjustment.
    func applyMatchOutcome(_ outcome: ChessMatchOutcome, opponentRating: Int) -> ChessRatingProfile {
        AppLogger.service.log("Applying match outcome: \(outcome) vs \(opponentRating)", .info)
        var profile = store.loadProfile()
        let expectedScore = expectedScore(
            playerRating: profile.userRating,
            opponentRating: opponentRating
        )
        let actualScore = score(for: outcome)
        let delta = Int((kFactor * (actualScore - expectedScore)).rounded())
        profile.userRating = ChessRatingProfile.clamp(profile.userRating + delta)
        store.saveProfile(profile)
        return profile
    }

    /// Calculates the expected score for a player in an Elo system.
    /// - Parameters:
    ///   - playerRating: The player's current rating.
    ///   - opponentRating: The opponent's current rating.
    /// - Returns: Success probability in the [0, 1] range.
    private func expectedScore(playerRating: Int, opponentRating: Int) -> Double {
        1.0 / (1.0 + pow(10.0, Double(opponentRating - playerRating) / 400.0))
    }

    /// Converts a match result into the numeric score used by Elo.
    /// - Parameter outcome: The completed match result.
    /// - Returns: Numeric shorthand for the score.
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

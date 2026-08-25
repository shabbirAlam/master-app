import Foundation

/// Persistence contract for the chess rating profile.
protocol ChessRatingStore: Sendable {
    /// Reads the persisted profile.
    /// - Returns: The stored rating profile.
    func loadProfile() -> ChessRatingProfile
    /// Writes the provided profile to storage.
    /// - Parameter profile: The new rating data to persist.
    func saveProfile(_ profile: ChessRatingProfile)
}

/// In-memory store used for previews and tests where persistence is not required.
final class InMemoryChessRatingStore: ChessRatingStore, @unchecked Sendable {
    private var profile: ChessRatingProfile

    /// Creates a store with an initial profile value.
    /// - Parameter profile: The starting rating profile.
    init(profile: ChessRatingProfile = ChessRatingProfile()) {
        self.profile = profile
    }

    /// Loads the in-memory values.
    func loadProfile() -> ChessRatingProfile {
        profile
    }

    /// Saves the profile to the current in-memory instance.
    /// - Parameter profile: The updated rating profile.
    func saveProfile(_ profile: ChessRatingProfile) {
        self.profile = profile
    }
}

/// `UserDefaults`-backed storage for chess ratings.
struct UserDefaultsChessRatingStore: ChessRatingStore {
    private enum Keys {
        static let userRating = "chess.userRating"
        static let computerRating = "chess.computerRating"
    }

    private let userDefaults: UserDefaults

    /// Creates a persistent store backed by the standard user defaults suite.
    /// - Parameter userDefaults: The defaults instance to use.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Reads the stored player and computer ratings.
    /// - Returns: The persisted chess rating profile or default values if not present.
    func loadProfile() -> ChessRatingProfile {
        let storedUserRating = userDefaults.object(forKey: Keys.userRating) as? Int
        let storedComputerRating = userDefaults.object(forKey: Keys.computerRating) as? Int

        return ChessRatingProfile(
            userRating: storedUserRating ?? ChessRatingProfile.defaultRating,
            computerRating: storedComputerRating ?? ChessRatingProfile.defaultRating
        )
    }

    /// Saves the profile to standard user defaults.
    /// - Parameter profile: The profile to persist.
    func saveProfile(_ profile: ChessRatingProfile) {
        userDefaults.set(profile.userRating, forKey: Keys.userRating)
        userDefaults.set(profile.computerRating, forKey: Keys.computerRating)
    }
}

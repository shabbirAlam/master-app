import Foundation

protocol ChessRatingStore: Sendable {
    func loadProfile() -> ChessRatingProfile
    func saveProfile(_ profile: ChessRatingProfile)
}

final class InMemoryChessRatingStore: ChessRatingStore, @unchecked Sendable {
    private var profile: ChessRatingProfile

    init(profile: ChessRatingProfile = ChessRatingProfile()) {
        self.profile = profile
    }

    func loadProfile() -> ChessRatingProfile {
        profile
    }

    func saveProfile(_ profile: ChessRatingProfile) {
        self.profile = profile
    }
}

struct UserDefaultsChessRatingStore: ChessRatingStore {
    private enum Keys {
        static let userRating = "chess.userRating"
        static let computerRating = "chess.computerRating"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadProfile() -> ChessRatingProfile {
        let storedUserRating = userDefaults.object(forKey: Keys.userRating) as? Int
        let storedComputerRating = userDefaults.object(forKey: Keys.computerRating) as? Int

        return ChessRatingProfile(
            userRating: storedUserRating ?? ChessRatingProfile.defaultRating,
            computerRating: storedComputerRating ?? ChessRatingProfile.defaultRating
        )
    }

    func saveProfile(_ profile: ChessRatingProfile) {
        userDefaults.set(profile.userRating, forKey: Keys.userRating)
        userDefaults.set(profile.computerRating, forKey: Keys.computerRating)
    }
}

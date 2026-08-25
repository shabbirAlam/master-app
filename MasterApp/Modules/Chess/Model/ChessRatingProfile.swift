import Foundation

/// Represents the Elo-style rating profile shared by the chess feature.
///
/// The profile tracks the player's current rating and the computer opponent's
/// rating while enforcing a fixed range so values remain stable and usable.
struct ChessRatingProfile: Equatable, Sendable {
    /// Default rating used for a new player or opponent profile.
    static let defaultRating = 600
    /// Minimum rating allowed in the app.
    static let minimumRating = 100
    /// Maximum rating allowed in the app.
    static let maximumRating = 2_400
    /// Rating change granularity used by chess progression logic.
    static let ratingStep = 100

    /// The player's rating.
    var userRating: Int
    /// The computer opponent's rating.
    var computerRating: Int

    /// Creates a rating profile with clamped values.
    /// - Parameters:
    ///   - userRating: The current user rating.
    ///   - computerRating: The current computer rating.
    init(
        userRating: Int = ChessRatingProfile.defaultRating,
        computerRating: Int = ChessRatingProfile.defaultRating
    ) {
        self.userRating = ChessRatingProfile.clamp(userRating)
        self.computerRating = ChessRatingProfile.clamp(computerRating)
    }

    /// Keeps the rating inside the valid range used by the app.
    /// - Parameter rating: The raw rating value.
    /// - Returns: A clamped value inside the configured bounds.
    static func clamp(_ rating: Int) -> Int {
        min(max(rating, minimumRating), maximumRating)
    }
}

/// The outcome of a completed chess match used to update ratings.
enum ChessMatchOutcome: Equatable, Sendable {
    /// The user won the match.
    case win
    /// The user lost the match.
    case loss
    /// The result was a draw.
    case draw
}

import Foundation

struct ChessRatingProfile: Equatable, Sendable {
    static let defaultRating = 600
    static let minimumRating = 100
    static let maximumRating = 2_400
    static let ratingStep = 100

    var userRating: Int
    var computerRating: Int

    init(
        userRating: Int = ChessRatingProfile.defaultRating,
        computerRating: Int = ChessRatingProfile.defaultRating
    ) {
        self.userRating = ChessRatingProfile.clamp(userRating)
        self.computerRating = ChessRatingProfile.clamp(computerRating)
    }

    static func clamp(_ rating: Int) -> Int {
        min(max(rating, minimumRating), maximumRating)
    }
}

enum ChessMatchOutcome: Equatable, Sendable {
    case win
    case loss
    case draw
}

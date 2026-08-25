import Foundation

/// A chess puzzle loaded from the local database, defined by a FEN position
/// and the expected sequence of moves.
struct ChessPuzzle: Identifiable, Sendable {
    /// Unique puzzle identifier.
    let id: String
    /// The puzzle display title.
    let title: String
    /// Difficulty rating.
    let rating: Int
    /// The starting position in FEN notation.
    let fen: String
    /// An optional opponent premove played before the user's turn.
    let premove: String?
    /// The UCI moves the user must find, in order.
    let expectedMoves: [String]
    /// The opponent's UCI replies after each expected move.
    let responseMoves: [String]

    /// Number of moves the user must make to solve the puzzle.
    var totalSteps: Int { expectedMoves.count }
}

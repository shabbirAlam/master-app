import Foundation

/// Repository contract for retrieving and selecting chess puzzles.
///
/// Puzzle data may be backed by a local SQLite database or another in-memory
/// source, but consumers only rely on the abstract repository interface.
protocol PuzzleRepository: Sendable {
    /// Returns a random puzzle near the requested rating while optionally excluding one ID.
    /// - Parameters:
    ///   - id: The puzzle ID to exclude, if any.
    ///   - rating: The target rating to search near.
    ///   - range: The acceptable rating spread around the target.
    /// - Returns: A matching puzzle, or `nil` when no puzzle matches the request.
    func randomPuzzle(excluding id: String?, near rating: Int, range: Int) throws -> ChessPuzzle?
    /// Fetches all puzzles in a rating band centered around the provided rating.
    /// - Parameters:
    ///   - rating: The target rating.
    ///   - range: The acceptable distance from that rating.
    /// - Returns: A list of puzzles in the requested band.
    func puzzles(near rating: Int, range: Int) throws -> [ChessPuzzle]
    /// Counts the puzzles near a rating threshold.
    /// - Parameters:
    ///   - rating: The target rating.
    ///   - range: The acceptable distance from that rating.
    /// - Returns: The number of puzzles that match the query.
    func puzzleCount(near rating: Int, range: Int) throws -> Int
    /// Fetches a puzzle by its unique identifier.
    /// - Parameter id: The puzzle identifier.
    /// - Returns: The matching puzzle, if present.
    func puzzleById(_ id: String) throws -> ChessPuzzle?
}

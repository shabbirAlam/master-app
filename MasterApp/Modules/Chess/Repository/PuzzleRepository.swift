import Foundation

protocol PuzzleRepository: Sendable {
    func randomPuzzle(excluding id: String?, near rating: Int, range: Int) throws -> ChessPuzzle?
    func puzzles(near rating: Int, range: Int) throws -> [ChessPuzzle]
    func puzzleCount(near rating: Int, range: Int) throws -> Int
    func puzzleById(_ id: String) throws -> ChessPuzzle?
}

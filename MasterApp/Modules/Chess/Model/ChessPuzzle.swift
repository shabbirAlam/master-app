import Foundation

struct ChessPuzzle: Identifiable, Sendable {
    let id: String
    let title: String
    let rating: Int
    let fen: String
    let premove: String?
    let expectedMoves: [String]
    let responseMoves: [String]

    var totalSteps: Int { expectedMoves.count }
}

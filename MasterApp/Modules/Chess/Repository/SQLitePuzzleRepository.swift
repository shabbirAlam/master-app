import Foundation
import SQLite3

final class SQLitePuzzleRepository: PuzzleRepository, @unchecked Sendable {
    private nonisolated(unsafe) let db: OpaquePointer?

    init() {
        let url = Bundle(for: SQLitePuzzleRepository.self).url(forResource: "puzzles_l10moves", withExtension: "db")
        db = url.flatMap { url in
            var handle: OpaquePointer?
            let rc = sqlite3_open_v2(url.path, &handle, SQLITE_OPEN_READONLY, nil)
            return rc == SQLITE_OK ? handle : nil
        }
    }

    deinit {
        if let db { sqlite3_close(db) }
    }

    func randomPuzzle(excluding id: String?, near rating: Int, range: Int) throws -> ChessPuzzle? {
        guard let db else { return nil }
        let minRating = max(100, rating - range)
        let maxRating = rating + range

        let sql: String
        let bind: (OpaquePointer) -> Void

        if let excludeId = id {
            sql = "SELECT PuzzleId, FEN, Moves, Rating FROM puzzles WHERE Rating BETWEEN ? AND ? AND PuzzleId != ? ORDER BY RANDOM() LIMIT 1"
            bind = { stmt in
                sqlite3_bind_int(stmt, 1, Int32(minRating))
                sqlite3_bind_int(stmt, 2, Int32(maxRating))
                sqlite3_bind_text(stmt, 3, (excludeId as NSString).utf8String, -1, nil)
            }
        } else {
            sql = "SELECT PuzzleId, FEN, Moves, Rating FROM puzzles WHERE Rating BETWEEN ? AND ? ORDER BY RANDOM() LIMIT 1"
            bind = { stmt in
                sqlite3_bind_int(stmt, 1, Int32(minRating))
                sqlite3_bind_int(stmt, 2, Int32(maxRating))
            }
        }

        return queryOne(sql: sql, bind: bind)
    }

    func puzzles(near rating: Int, range: Int) throws -> [ChessPuzzle] {
        guard let db else { return [] }
        let minRating = max(100, rating - range)
        let maxRating = rating + range

        let sql = "SELECT PuzzleId, FEN, Moves, Rating FROM puzzles WHERE Rating BETWEEN ? AND ? ORDER BY RANDOM() LIMIT 50"
        return queryMany(sql: sql) { stmt in
            sqlite3_bind_int(stmt, 1, Int32(minRating))
            sqlite3_bind_int(stmt, 2, Int32(maxRating))
        }
    }

    func puzzleById(_ id: String) throws -> ChessPuzzle? {
        guard let db else { return nil }
        let sql = "SELECT PuzzleId, FEN, Moves, Rating FROM puzzles WHERE PuzzleId = ? LIMIT 1"
        return queryOne(sql: sql) { stmt in
            sqlite3_bind_text(stmt, 1, (id as NSString).utf8String, -1, nil)
        }
    }

    func puzzleCount(near rating: Int, range: Int) throws -> Int {
        guard let db else { return 0 }
        let minRating = max(100, rating - range)
        let maxRating = rating + range

        let sql = "SELECT COUNT(*) FROM puzzles WHERE Rating BETWEEN ? AND ?"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return 0 }
        guard let stmt else { return 0 }
        sqlite3_bind_int(stmt, 1, Int32(minRating))
        sqlite3_bind_int(stmt, 2, Int32(maxRating))

        var count = 0
        if sqlite3_step(stmt) == SQLITE_ROW {
            count = Int(sqlite3_column_int(stmt, 0))
        }
        sqlite3_finalize(stmt)
        return count
    }

    private func queryOne(sql: String, bind: (OpaquePointer) -> Void) -> ChessPuzzle? {
        queryMany(sql: sql, bind: bind).first
    }

    private func queryMany(sql: String, bind: (OpaquePointer) -> Void) -> [ChessPuzzle] {
        guard let db else { return [] }
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        guard let stmt else { return [] }
        bind(stmt)

        var results: [ChessPuzzle] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            guard
                let puzzleId = sqlite3_column_text(stmt, 0).map({ String(cString: $0) }),
                let fen = sqlite3_column_text(stmt, 1).map({ String(cString: $0) }),
                let movesStr = sqlite3_column_text(stmt, 2).map({ String(cString: $0) })
            else { continue }
            let rating = Int(sqlite3_column_int(stmt, 3))

            let moves = movesStr.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
            let premove = moves.count > 0 ? moves[0] : nil
            let remaining = moves.count > 1 ? Array(moves[1...]) : []
            let expectedMoves = stride(from: 0, to: remaining.count, by: 2).map { remaining[$0] }
            let responseMoves = stride(from: 1, to: remaining.count, by: 2).map { remaining[$0] }

            results.append(ChessPuzzle(
                id: puzzleId,
                title: puzzleId,
                rating: rating,
                fen: fen,
                premove: premove,
                expectedMoves: expectedMoves,
                responseMoves: responseMoves
            ))
        }
        sqlite3_finalize(stmt)
        return results
    }
}

import Foundation

/// A complete, value-semantic chess game state: board, turn, status,
/// history, captured pieces, en-passant target, castling rights, and an
/// undo stack.
struct GameState: Equatable, Sendable {
    /// The 8x8 board; index `[row][col]` with row 0 = rank 8.
    var board: [[ChessPiece?]]
    /// The side to move next.
    var currentTurn: PieceColor
    /// The current game status (playing/check/checkmate/stalemate).
    var status: GameStatus
    /// All moves played so far.
    var moveHistory: [Move]
    /// Pieces captured by each color, keyed by capturing color.
    var capturedPieces: [PieceColor: [ChessPiece]]
    /// The square vulnerable to en passant, if a pawn just advanced two ranks.
    var enPassantTarget: Position?
    /// Castling availability per color.
    var castlingRights: [PieceColor: CastlingRights]
    /// Snapshots of prior states enabling undo.
    private(set) var undoStack: [GameState] = []

    /// Per-color castling availability flags.
    struct CastlingRights: Equatable, Sendable {
        /// Whether kingside castling is still allowed.
        var kingside: Bool
        /// Whether queenside castling is still allowed.
        var queenside: Bool
    }

    /// Creates a state with the standard starting position and white to move.
    init() {
        self.board = Self.initialBoard()
        self.currentTurn = .white
        self.status = .playing
        self.moveHistory = []
        self.capturedPieces = [.white: [], .black: []]
        self.enPassantTarget = nil
        self.castlingRights = [
            .white: CastlingRights(kingside: true, queenside: true),
            .black: CastlingRights(kingside: true, queenside: true)
        ]
    }

    /// Builds the standard chess starting position.
    /// - Returns: An 8x8 board with pieces in initial placement.
    static func initialBoard() -> [[ChessPiece?]] {
        var board = [[ChessPiece?]](
            repeating: [ChessPiece?](repeating: nil, count: 8),
            count: 8
        )
        let backRank: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        for col in 0..<8 {
            board[0][col] = ChessPiece(type: backRank[col], color: .black)
            board[1][col] = ChessPiece(type: .pawn, color: .black)
            board[6][col] = ChessPiece(type: .pawn, color: .white)
            board[7][col] = ChessPiece(type: backRank[col], color: .white)
        }
        return board
    }

    nonisolated func piece(at position: Position) -> ChessPiece? {
        guard (0..<8).contains(position.row), (0..<8).contains(position.col) else { return nil }
        return board[position.row][position.col]
    }

    nonisolated func isInBounds(_ pos: Position) -> Bool {
        (0..<8).contains(pos.row) && (0..<8).contains(pos.col)
    }

    nonisolated func findKing(_ color: PieceColor) -> Position? {
        for row in 0..<8 {
            for col in 0..<8 {
                if board[row][col] == ChessPiece(type: .king, color: color) {
                    return Position(row: row, col: col)
                }
            }
        }
        return nil
    }

    nonisolated func isSquareAttacked(_ pos: Position, by color: PieceColor) -> Bool {
        let pawnDir: Int = color == .white ? 1 : -1
        for dCol in [-1, 1] {
            let attackerPos = Position(row: pos.row + pawnDir, col: pos.col + dCol)
            if isInBounds(attackerPos), piece(at: attackerPos) == ChessPiece(type: .pawn, color: color) {
                return true
            }
        }

        let knightMoves: [(Int, Int)] = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)]
        for (dr, dc) in knightMoves {
            let attackerPos = Position(row: pos.row + dr, col: pos.col + dc)
            if isInBounds(attackerPos), piece(at: attackerPos) == ChessPiece(type: .knight, color: color) {
                return true
            }
        }

        let kingMoves: [(Int, Int)] = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
        for (dr, dc) in kingMoves {
            let attackerPos = Position(row: pos.row + dr, col: pos.col + dc)
            if isInBounds(attackerPos), piece(at: attackerPos) == ChessPiece(type: .king, color: color) {
                return true
            }
        }

        let bishopDirs: [(Int, Int)] = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
        for (dr, dc) in bishopDirs {
            var r = pos.row + dr
            var c = pos.col + dc
            while (0..<8).contains(r) && (0..<8).contains(c) {
                if let p = board[r][c] {
                    if p.color == color && (p.type == .bishop || p.type == .queen) {
                        return true
                    }
                    break
                }
                r += dr
                c += dc
            }
        }

        let rookDirs: [(Int, Int)] = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        for (dr, dc) in rookDirs {
            var r = pos.row + dr
            var c = pos.col + dc
            while (0..<8).contains(r) && (0..<8).contains(c) {
                if let p = board[r][c] {
                    if p.color == color && (p.type == .rook || p.type == .queen) {
                        return true
                    }
                    break
                }
                r += dr
                c += dc
            }
        }

        return false
    }

    nonisolated func isInCheck(_ color: PieceColor) -> Bool {
        guard let kingPos = findKing(color) else { return false }
        return isSquareAttacked(kingPos, by: color.opponent)
    }

    nonisolated func pseudoLegalMoves(at position: Position) -> [Move] {
        guard let movingPiece = self.piece(at: position), movingPiece.color == currentTurn else { return [] }
        var moves: [Move] = []

        switch movingPiece.type {
        case .pawn:
            let dir: Int = movingPiece.color == .white ? -1 : 1
            let startRow = movingPiece.color == .white ? 6 : 1
            let promoRow = movingPiece.color == .white ? 0 : 7

            let forward1 = Position(row: position.row + dir, col: position.col)
            if isInBounds(forward1), self.piece(at: forward1) == nil {
                if forward1.row == promoRow {
                    for promoType in [PieceType.queen, .rook, .bishop, .knight] {
                        moves.append(Move(from: position, to: forward1, captured: nil, promotion: promoType, isCastling: false, isEnPassant: false))
                    }
                } else {
                    moves.append(Move(from: position, to: forward1, captured: nil, promotion: nil, isCastling: false, isEnPassant: false))
                }
                if position.row == startRow {
                    let forward2 = Position(row: position.row + 2 * dir, col: position.col)
                    if self.piece(at: forward2) == nil {
                        moves.append(Move(from: position, to: forward2, captured: nil, promotion: nil, isCastling: false, isEnPassant: false))
                    }
                }
            }

            for dCol in [-1, 1] {
                let capturePos = Position(row: position.row + dir, col: position.col + dCol)
                guard isInBounds(capturePos) else { continue }
                if let captured = self.piece(at: capturePos), captured.color != movingPiece.color {
                    if capturePos.row == promoRow {
                        for promoType in [PieceType.queen, .rook, .bishop, .knight] {
                            moves.append(Move(from: position, to: capturePos, captured: captured, promotion: promoType, isCastling: false, isEnPassant: false))
                        }
                    } else {
                        moves.append(Move(from: position, to: capturePos, captured: captured, promotion: nil, isCastling: false, isEnPassant: false))
                    }
                }
                if capturePos == enPassantTarget {
                    if let capturedPawn = self.piece(at: Position(row: position.row, col: capturePos.col)) {
                        moves.append(Move(from: position, to: capturePos, captured: capturedPawn, promotion: nil, isCastling: false, isEnPassant: true))
                    }
                }
            }

        case .knight:
            let offsets: [(Int, Int)] = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)]
            for (dr, dc) in offsets {
                let to = Position(row: position.row + dr, col: position.col + dc)
                guard isInBounds(to) else { continue }
                if let target = self.piece(at: to) {
                    if target.color != movingPiece.color {
                        moves.append(Move(from: position, to: to, captured: target, promotion: nil, isCastling: false, isEnPassant: false))
                    }
                } else {
                    moves.append(Move(from: position, to: to, captured: nil, promotion: nil, isCastling: false, isEnPassant: false))
                }
            }

        case .bishop:
            let dirs: [(Int, Int)] = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
            for (dr, dc) in dirs {
                var r = position.row + dr
                var c = position.col + dc
                while (0..<8).contains(r) && (0..<8).contains(c) {
                    let to = Position(row: r, col: c)
                    if let target = board[r][c] {
                        if target.color != movingPiece.color {
                            moves.append(Move(from: position, to: to, captured: target, promotion: nil, isCastling: false, isEnPassant: false))
                        }
                        break
                    }
                    moves.append(Move(from: position, to: to, captured: nil, promotion: nil, isCastling: false, isEnPassant: false))
                    r += dr
                    c += dc
                }
            }

        case .rook:
            let dirs: [(Int, Int)] = [(0, 1), (0, -1), (1, 0), (-1, 0)]
            for (dr, dc) in dirs {
                var r = position.row + dr
                var c = position.col + dc
                while (0..<8).contains(r) && (0..<8).contains(c) {
                    let to = Position(row: r, col: c)
                    if let target = board[r][c] {
                        if target.color != movingPiece.color {
                            moves.append(Move(from: position, to: to, captured: target, promotion: nil, isCastling: false, isEnPassant: false))
                        }
                        break
                    }
                    moves.append(Move(from: position, to: to, captured: nil, promotion: nil, isCastling: false, isEnPassant: false))
                    r += dr
                    c += dc
                }
            }

        case .queen:
            let dirs: [(Int, Int)] = [(0, 1), (0, -1), (1, 0), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]
            for (dr, dc) in dirs {
                var r = position.row + dr
                var c = position.col + dc
                while (0..<8).contains(r) && (0..<8).contains(c) {
                    let to = Position(row: r, col: c)
                    if let target = board[r][c] {
                        if target.color != movingPiece.color {
                            moves.append(Move(from: position, to: to, captured: target, promotion: nil, isCastling: false, isEnPassant: false))
                        }
                        break
                    }
                    moves.append(Move(from: position, to: to, captured: nil, promotion: nil, isCastling: false, isEnPassant: false))
                    r += dr
                    c += dc
                }
            }

        case .king:
            let offsets: [(Int, Int)] = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
            for (dr, dc) in offsets {
                let to = Position(row: position.row + dr, col: position.col + dc)
                guard isInBounds(to) else { continue }
                if let target = self.piece(at: to) {
                    if target.color != movingPiece.color {
                        moves.append(Move(from: position, to: to, captured: target, promotion: nil, isCastling: false, isEnPassant: false))
                    }
                } else {
                    moves.append(Move(from: position, to: to, captured: nil, promotion: nil, isCastling: false, isEnPassant: false))
                }
            }

            if let rights = castlingRights[movingPiece.color] {
                if !isInCheck(movingPiece.color) {
                    if rights.kingside {
                        let rookPos = Position(row: position.row, col: 7)
                        if let rook = self.piece(at: rookPos), rook == ChessPiece(type: .rook, color: movingPiece.color) {
                            let pathClear = self.piece(at: Position(row: position.row, col: 5)) == nil
                                && self.piece(at: Position(row: position.row, col: 6)) == nil
                            let notThroughCheck = !isSquareAttacked(Position(row: position.row, col: 5), by: movingPiece.color.opponent)
                                && !isSquareAttacked(Position(row: position.row, col: 6), by: movingPiece.color.opponent)
                            if pathClear && notThroughCheck {
                                moves.append(Move(from: position, to: Position(row: position.row, col: 6), captured: nil, promotion: nil, isCastling: true, isEnPassant: false))
                            }
                        }
                    }
                    if rights.queenside {
                        let rookPos = Position(row: position.row, col: 0)
                        if let rook = self.piece(at: rookPos), rook == ChessPiece(type: .rook, color: movingPiece.color) {
                            let pathClear = self.piece(at: Position(row: position.row, col: 1)) == nil
                                && self.piece(at: Position(row: position.row, col: 2)) == nil
                                && self.piece(at: Position(row: position.row, col: 3)) == nil
                            let notThroughCheck = !isSquareAttacked(Position(row: position.row, col: 2), by: movingPiece.color.opponent)
                                && !isSquareAttacked(Position(row: position.row, col: 3), by: movingPiece.color.opponent)
                            if pathClear && notThroughCheck {
                                moves.append(Move(from: position, to: Position(row: position.row, col: 2), captured: nil, promotion: nil, isCastling: true, isEnPassant: false))
                            }
                        }
                    }
                }
            }
        }

        return moves
    }

    nonisolated func legalMoves(at position: Position) -> [Move] {
        guard let opponentKingPos = findKing(currentTurn.opponent) else { return [] }
        return pseudoLegalMoves(at: position).filter { move in
            guard move.to != opponentKingPos else { return false }
            var newState = self
            newState._applyMoveWithoutStatusUpdate(move)
            return !newState.isInCheck(self.currentTurn)
        }
    }

    nonisolated func allLegalMoves(for color: PieceColor? = nil) -> [Move] {
        let color = color ?? currentTurn
        var allMoves: [Move] = []
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = board[row][col], piece.color == color {
                    allMoves.append(contentsOf: legalMoves(at: pos))
                }
            }
        }
        return allMoves
    }

    nonisolated mutating func applyMove(_ move: Move) {
        undoStack.append(self)
        _applyMoveWithoutStatusUpdate(move)
        updateStatus()
    }

    nonisolated mutating func undoLastMove() -> Bool {
        guard let previous = undoStack.popLast() else { return false }
        self = previous
        return true
    }

    private nonisolated mutating func _applyMoveWithoutStatusUpdate(_ move: Move) {
        let piece = board[move.from.row][move.from.col]!

        if move.isEnPassant {
            board[move.from.row][move.to.col] = nil
        }

        if move.isCastling {
            if move.to.col == 6 {
                board[move.from.row][5] = board[move.from.row][7]
                board[move.from.row][7] = nil
            } else if move.to.col == 2 {
                board[move.from.row][3] = board[move.from.row][0]
                board[move.from.row][0] = nil
            }
        }

        board[move.to.row][move.to.col] = piece
        board[move.from.row][move.from.col] = nil

        if let promo = move.promotion {
            board[move.to.row][move.to.col] = ChessPiece(type: promo, color: piece.color)
        }

        enPassantTarget = nil
        if piece.type == .pawn && abs(move.to.row - move.from.row) == 2 {
            enPassantTarget = Position(row: (move.from.row + move.to.row) / 2, col: move.from.col)
        }

        if piece.type == .king {
            castlingRights[piece.color] = CastlingRights(kingside: false, queenside: false)
        }
        if piece.type == .rook {
            if move.from == Position(row: piece.color == .white ? 7 : 0, col: 0) {
                castlingRights[piece.color]?.queenside = false
            }
            if move.from == Position(row: piece.color == .white ? 7 : 0, col: 7) {
                castlingRights[piece.color]?.kingside = false
            }
        }

        if let captured = move.captured {
            if captured.type == .rook {
                switch move.to {
                case Position(row: 7, col: 0):
                    castlingRights[.white]?.queenside = false
                case Position(row: 7, col: 7):
                    castlingRights[.white]?.kingside = false
                case Position(row: 0, col: 0):
                    castlingRights[.black]?.queenside = false
                case Position(row: 0, col: 7):
                    castlingRights[.black]?.kingside = false
                default:
                    break
                }
            }
            capturedPieces[piece.color]?.append(captured)
        }

        moveHistory.append(move)
        currentTurn = currentTurn.opponent
    }

    nonisolated mutating func updateStatus() {
        let allMoves = allLegalMoves(for: currentTurn)
        if allMoves.isEmpty {
            if isInCheck(currentTurn) {
                status = .checkmate(winner: currentTurn.opponent)
            } else {
                status = .stalemate
            }
        } else if isInCheck(currentTurn) {
            status = .check
        } else {
            status = .playing
        }
    }
}

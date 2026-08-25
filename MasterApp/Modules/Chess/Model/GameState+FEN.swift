import Foundation

/// Parses a chess position from a FEN string and initializes the in-memory game state.
extension GameState {
    /// Builds a board state from the standard FEN representation used by chess engines and puzzles.
    /// - Parameter fen: The FEN string describing the board layout, active side, castling rights, and en passant target.
    init?(fen: String) {
        let parts = fen.split(separator: " ")
        guard parts.count >= 4 else { return nil }

        let boardPart = String(parts[0])
        let activePart = String(parts[1])
        let castlingPart = String(parts[2])
        let enPassantPart = String(parts[3])

        var board = [[ChessPiece?]](repeating: [ChessPiece?](repeating: nil, count: 8), count: 8)
        let ranks = boardPart.split(separator: "/")
        guard ranks.count == 8 else { return nil }

        for (row, rank) in ranks.enumerated() {
            var col = 0
            for char in rank {
                guard col < 8 else { return nil }
                if let emptyCount = char.wholeNumberValue {
                    col += emptyCount
                } else if let piece = ChessPiece(fen: char) {
                    board[row][col] = piece
                    col += 1
                } else {
                    return nil
                }
            }
        }

        let currentTurn: PieceColor = activePart == "b" ? .black : .white

        var castlingRights: [PieceColor: CastlingRights] = [
            .white: CastlingRights(kingside: false, queenside: false),
            .black: CastlingRights(kingside: false, queenside: false)
        ]
        if castlingPart != "-" {
            for char in castlingPart {
                switch char {
                case "K": castlingRights[.white]?.kingside = true
                case "Q": castlingRights[.white]?.queenside = true
                case "k": castlingRights[.black]?.kingside = true
                case "q": castlingRights[.black]?.queenside = true
                default: break
                }
            }
        }

        var enPassantTarget: Position? = nil
        if enPassantPart != "-" {
            enPassantTarget = Position(chessNotation: enPassantPart)
        }

        self.board = board
        self.currentTurn = currentTurn
        self.status = .playing
        self.moveHistory = []
        self.capturedPieces = [.white: [], .black: []]
        self.enPassantTarget = enPassantTarget
        self.castlingRights = castlingRights

        updateStatus()
    }
}

/// Maps a FEN board character such as "Q" or "p" into a chess piece definition.
extension ChessPiece {
    /// Creates a piece from a single FEN character.
    /// - Parameter fen: The one-character FEN notation for a piece.
    init?(fen: Character) {
        let isWhite = fen.isUppercase
        let lower = fen.lowercased()
        guard let pieceType: PieceType = {
            switch lower {
            case "p": return .pawn
            case "n": return .knight
            case "b": return .bishop
            case "r": return .rook
            case "q": return .queen
            case "k": return .king
            default: return nil
            }
        }() else { return nil }
        self.init(type: pieceType, color: isWhite ? .white : .black)
    }
}

/// Parses a two-character chess square such as "e4" into a board coordinate.
extension Position {
    /// Creates a board coordinate from algebraic notation.
    /// - Parameter chessNotation: A square like "e4" or "a8".
    init?(chessNotation: String) {
        guard chessNotation.count == 2 else { return nil }
        let colChar = chessNotation[chessNotation.startIndex]
        let rowChar = chessNotation[chessNotation.index(after: chessNotation.startIndex)]
        guard let file = colChar.asciiValue, file >= 97, file <= 104 else { return nil }
        guard let rank = rowChar.asciiValue, rank >= 49, rank <= 56 else { return nil }
        self.init(row: 7 - Int(rank - 49), col: Int(file - 97))
    }
}

/// Applies a UCI move string directly to the current game state.
extension GameState {
    /// Attempts to apply a legal move represented in UCI format.
    /// - Parameter uci: A move like "e2e4" or "g7g8q".
    /// - Returns: `true` when the move is valid and applied successfully.
    mutating func applyUCIMove(_ uci: String) -> Bool {
        guard uci.count >= 4 else { return false }
        let from = String(uci[uci.startIndex..<uci.index(uci.startIndex, offsetBy: 2)])
        let to = String(uci[uci.index(uci.startIndex, offsetBy: 2)..<uci.index(uci.startIndex, offsetBy: 4)])
        let promotionChar: Character? = uci.count >= 5 ? uci[uci.index(uci.startIndex, offsetBy: 4)] : nil

        guard let fromPos = Position(chessNotation: from),
              let toPos = Position(chessNotation: to) else { return false }

        let legal = legalMoves(at: fromPos)
        guard let matchedMove = legal.first(where: { candidate in
            guard candidate.to == toPos else { return false }
            if let promo = promotionChar, let promoType = PieceType(pgn: promo) {
                return candidate.promotion == promoType
            }
            return candidate.promotion == nil
        }) else { return false }

        applyMove(matchedMove)
        return true
    }
}

/// Converts a promotion character into a chess piece type.
extension PieceType {
    /// Builds a promotion type from the single-character PGN value.
    /// - Parameter pgn: The piece letter used in promotion notation.
    init?(pgn: Character) {
        switch pgn {
        case "N": self = .knight
        case "B": self = .bishop
        case "R": self = .rook
        case "Q": self = .queen
        default: return nil
        }
    }
}

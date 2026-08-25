import Foundation

/// The color side of a chess piece.
enum PieceColor: String, Equatable, Hashable, CaseIterable, Sendable {
    /// The white pieces.
    case white
    /// The black pieces.
    case black

    /// The opposite color.
    nonisolated var opponent: PieceColor { self == .white ? .black : .white }
}

/// The type of a chess piece.
enum PieceType: String, Equatable, Hashable, CaseIterable, Sendable {
    case king, queen, rook, bishop, knight, pawn

    /// The uppercase letter used in algebraic notation (empty for pawns).
    nonisolated var notationSymbol: String {
        switch self {
        case .king: "K"
        case .queen: "Q"
        case .rook: "R"
        case .bishop: "B"
        case .knight: "N"
        case .pawn: ""
        }
    }
}

/// A chess piece combining type and color, with Unicode and asset
/// representations plus standard material values.
struct ChessPiece: Hashable, Sendable {
    /// The kind of piece.
    let type: PieceType
    /// The side the piece belongs to.
    let color: PieceColor

    /// Equality based on type and color.
    nonisolated static func == (lhs: ChessPiece, rhs: ChessPiece) -> Bool {
        lhs.type == rhs.type && lhs.color == rhs.color
    }

    /// The Unicode chess glyph for the piece.
    var symbol: String {
        switch (color, type) {
        case (.white, .king):   "\u{2654}"
        case (.white, .queen):  "\u{2655}"
        case (.white, .rook):   "\u{2656}"
        case (.white, .bishop): "\u{2657}"
        case (.white, .knight): "\u{2658}"
        case (.white, .pawn):   "\u{2659}"
        case (.black, .king):   "\u{265A}"
        case (.black, .queen):  "\u{265B}"
        case (.black, .rook):   "\u{265C}"
        case (.black, .bishop): "\u{265D}"
        case (.black, .knight): "\u{265E}"
        case (.black, .pawn):   "\u{265F}"
        }
    }

    /// The asset catalog name (e.g. `"wK"`, `"bP"`) for the piece image.
    nonisolated var assetName: String {
        let prefix = color == .white ? "w" : "b"
        let suffix: String
        switch type {
        case .king: suffix = "K"
        case .queen: suffix = "Q"
        case .rook: suffix = "R"
        case .bishop: suffix = "B"
        case .knight: suffix = "N"
        case .pawn: suffix = "P"
        }
        return prefix + suffix
    }

    /// The standard material value (pawn 1, knight/bishop 3, rook 5, queen 9, king 1000).
    nonisolated var value: Int {
        switch type {
        case .pawn:   1
        case .knight: 3
        case .bishop: 3
        case .rook:   5
        case .queen:  9
        case .king:   1000
        }
    }

    /// The notation letter for the piece type.
    nonisolated var notationSymbol: String { type.notationSymbol }
}

/// A square on the 8x8 board, indexed from the top-left (`row 0`, `col 0`).
struct Position: Hashable, Sendable {
    /// Row index 0 (rank 8) through 7 (rank 1).
    let row: Int
    /// Column index 0 (file a) through 7 (file h).
    let col: Int

    /// Equality based on row and column.
    nonisolated static func == (lhs: Position, rhs: Position) -> Bool {
        lhs.row == rhs.row && lhs.col == rhs.col
    }

    /// The algebraic coordinate (e.g. `"e4"`) for this square.
    nonisolated var algebraic: String {
        let file = String(Character(UnicodeScalar(97 + col) ?? "a"))
        let rank = String(8 - row)
        return file + rank
    }
}

/// A single chess move with capture, promotion, castling, and en-passant metadata.
struct Move: Equatable, Hashable, Sendable {
    /// The origin square.
    let from: Position
    /// The destination square.
    let to: Position
    /// The piece captured, if any.
    let captured: ChessPiece?
    /// The promotion piece type, if the move promotes a pawn.
    let promotion: PieceType?
    /// Whether this move is a castle.
    let isCastling: Bool
    /// Whether this move captures en passant.
    let isEnPassant: Bool

    /// Human-readable notation (e.g. `"xe5=Q"`, `"O-O"`).
    var notation: String {
        if isCastling {
            return to.col > from.col ? "O-O" : "O-O-O"
        }
        var result = ""
        if captured != nil {
            result += "x"
        }
        result += to.algebraic
        if let promo = promotion {
            result += "=\(promo.notationSymbol)"
        }
        if isEnPassant {
            result += " e.p."
        }
        return result
    }

    /// The UCI representation (e.g. `"e2e4"`, `"a7a8q"`).
    nonisolated var uci: String {
        from.algebraic + to.algebraic + (promotion.map { $0.notationSymbol.lowercased() } ?? "")
    }
}

/// The current state of a game in progress.
enum GameStatus: Equatable, Sendable {
    /// The game is ongoing with no check.
    case playing
    /// A side is in check.
    case check
    /// The game ended by checkmate; carries the winning color.
    case checkmate(winner: PieceColor)
    /// The game ended in stalemate (draw).
    case stalemate

    /// Whether the game has finished.
    nonisolated var isGameOver: Bool {
        switch self {
        case .checkmate, .stalemate: true
        case .playing, .check: false
        }
    }

    /// Whether the game ended by checkmate.
    nonisolated var isCheckmate: Bool {
        if case .checkmate = self { true } else { false }
    }

    /// Whether the given color won by checkmate.
    /// - Parameter color: The color to test.
    nonisolated func isCheckmate(winner color: PieceColor) -> Bool {
        if case .checkmate(let winner) = self, winner == color { true } else { false }
    }

    /// A user-facing status message (e.g. `"Checkmate! White wins!"`).
    nonisolated var message: String {
        switch self {
        case .playing: "Playing"
        case .check: "Check!"
        case .checkmate(let winner): "Checkmate! \(winner.rawValue.capitalized) wins!"
        case .stalemate: "Stalemate! Draw."
        }
    }
}

/// The selected play mode.
enum GameMode: Equatable, Sendable {
    /// Play against the built-in AI.
    case vsComputer
    /// Two players sharing the device.
    case twoPlayer
}

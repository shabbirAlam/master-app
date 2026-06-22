import Foundation

enum PieceColor: String, Equatable, Hashable, CaseIterable, Sendable {
    case white
    case black

    nonisolated var opponent: PieceColor { self == .white ? .black : .white }
}

enum PieceType: String, Equatable, Hashable, CaseIterable, Sendable {
    case king, queen, rook, bishop, knight, pawn

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

struct ChessPiece: Hashable, Sendable {
    let type: PieceType
    let color: PieceColor

    nonisolated static func == (lhs: ChessPiece, rhs: ChessPiece) -> Bool {
        lhs.type == rhs.type && lhs.color == rhs.color
    }

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

    nonisolated var notationSymbol: String { type.notationSymbol }
}

struct Position: Hashable, Sendable {
    let row: Int
    let col: Int

    nonisolated static func == (lhs: Position, rhs: Position) -> Bool {
        lhs.row == rhs.row && lhs.col == rhs.col
    }

    nonisolated var algebraic: String {
        let file = String(Character(UnicodeScalar(97 + col) ?? "a"))
        let rank = String(8 - row)
        return file + rank
    }
}

struct Move: Equatable, Hashable, Sendable {
    let from: Position
    let to: Position
    let captured: ChessPiece?
    let promotion: PieceType?
    let isCastling: Bool
    let isEnPassant: Bool

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

    nonisolated var uci: String {
        from.algebraic + to.algebraic + (promotion.map { $0.notationSymbol.lowercased() } ?? "")
    }
}

enum GameStatus: Equatable, Sendable {
    case playing
    case check
    case checkmate(winner: PieceColor)
    case stalemate

    nonisolated var isGameOver: Bool {
        switch self {
        case .checkmate, .stalemate: true
        case .playing, .check: false
        }
    }

    nonisolated var isCheckmate: Bool {
        if case .checkmate = self { true } else { false }
    }

    nonisolated func isCheckmate(winner color: PieceColor) -> Bool {
        if case .checkmate(let winner) = self, winner == color { true } else { false }
    }

    nonisolated var message: String {
        switch self {
        case .playing: "Playing"
        case .check: "Check!"
        case .checkmate(let winner): "Checkmate! \(winner.rawValue.capitalized) wins!"
        case .stalemate: "Stalemate! Draw."
        }
    }
}

enum GameMode: Equatable, Sendable {
    case vsComputer
    case twoPlayer
}

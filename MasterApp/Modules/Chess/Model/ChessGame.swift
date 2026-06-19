import Foundation

enum PieceColor: String, Equatable, Hashable, CaseIterable, Sendable {
    case white
    case black

    var opponent: PieceColor { self == .white ? .black : .white }
}

enum PieceType: String, Equatable, Hashable, CaseIterable, Sendable {
    case king, queen, rook, bishop, knight, pawn

    var notationSymbol: String {
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

struct ChessPiece: Equatable, Hashable, Sendable {
    let type: PieceType
    let color: PieceColor

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

    var value: Int {
        switch type {
        case .pawn:   1
        case .knight: 3
        case .bishop: 3
        case .rook:   5
        case .queen:  9
        case .king:   1000
        }
    }

    var notationSymbol: String { type.notationSymbol }
}

struct Position: Equatable, Hashable, Sendable {
    let row: Int
    let col: Int

    var algebraic: String {
        let file = String(UnicodeScalar(97 + col)!)
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
}

enum GameStatus: Equatable, Sendable {
    case playing
    case check
    case checkmate(winner: PieceColor)
    case stalemate

    var isGameOver: Bool {
        switch self {
        case .checkmate, .stalemate: true
        case .playing, .check: false
        }
    }

    var message: String {
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

struct GameState: Equatable, Sendable {
    var board: [[ChessPiece?]]
    var currentTurn: PieceColor
    var status: GameStatus
    var moveHistory: [Move]
    var capturedPieces: [PieceColor: [ChessPiece]]
    var enPassantTarget: Position?
    var castlingRights: [PieceColor: CastlingRights]

    struct CastlingRights: Equatable, Sendable {
        var kingside: Bool
        var queenside: Bool
    }

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

    func piece(at position: Position) -> ChessPiece? {
        guard (0..<8).contains(position.row), (0..<8).contains(position.col) else { return nil }
        return board[position.row][position.col]
    }

    func isInBounds(_ pos: Position) -> Bool {
        (0..<8).contains(pos.row) && (0..<8).contains(pos.col)
    }

    func findKing(_ color: PieceColor) -> Position? {
        for row in 0..<8 {
            for col in 0..<8 {
                if board[row][col] == ChessPiece(type: .king, color: color) {
                    return Position(row: row, col: col)
                }
            }
        }
        return nil
    }

    func isSquareAttacked(_ pos: Position, by color: PieceColor) -> Bool {
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

    func isInCheck(_ color: PieceColor) -> Bool {
        guard let kingPos = findKing(color) else { return false }
        return isSquareAttacked(kingPos, by: color.opponent)
    }

    func pseudoLegalMoves(at position: Position) -> [Move] {
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

    func legalMoves(at position: Position) -> [Move] {
        guard let opponentKingPos = findKing(currentTurn.opponent) else { return [] }
        return pseudoLegalMoves(at: position).filter { move in
            guard move.to != opponentKingPos else { return false }
            var newState = self
            newState._applyMoveWithoutStatusUpdate(move)
            return !newState.isInCheck(self.currentTurn)
        }
    }

    func allLegalMoves(for color: PieceColor? = nil) -> [Move] {
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

    mutating func applyMove(_ move: Move) {
        _applyMoveWithoutStatusUpdate(move)
        updateStatus()
    }

    private mutating func _applyMoveWithoutStatusUpdate(_ move: Move) {
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
            if move.from.col == 0 { castlingRights[piece.color]?.queenside = false }
            if move.from.col == 7 { castlingRights[piece.color]?.kingside = false }
        }
        if move.to.col == 0 {
            castlingRights[move.to.row == 0 ? .black : .white]?.queenside = false
        }
        if move.to.col == 7 {
            castlingRights[move.to.row == 0 ? .black : .white]?.kingside = false
        }

        if let captured = move.captured {
            capturedPieces[piece.color]?.append(captured)
        }

        moveHistory.append(move)
        currentTurn = currentTurn.opponent
    }

    mutating func updateStatus() {
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

    static func selectAIMove(from moves: [Move], in game: GameState, rating: Int) -> Move? {
        guard !moves.isEmpty else { return nil }

        let profile = ChessAIProfile(rating: rating)
        let orderedMoves = moves.sorted { lhs, rhs in
            heuristicScore(for: lhs, in: game) > heuristicScore(for: rhs, in: game)
        }
        var scoredMoves: [(Move, Int)] = []

        for move in orderedMoves {
            var newGame = game
            newGame.applyMove(move)

            var score = heuristicScore(for: move, in: game)
            if profile.searchDepth > 1, !newGame.status.isGameOver {
                score += -negamax(
                    game: newGame,
                    depth: profile.searchDepth - 1,
                    alpha: -100_000,
                    beta: 100_000,
                    maximizingColor: .black
                )
            } else {
                score += evaluateBoard(newGame, for: .black)
            }

            scoredMoves.append((move, score))
        }

        scoredMoves.sort { $0.1 > $1.1 }
        let candidateCount = min(profile.candidateCount, scoredMoves.count)
        let candidateMoves = Array(scoredMoves.prefix(candidateCount))

        if profile.randomness == 0 {
            return candidateMoves.first?.0
        }

        let randomizedMoves = candidateMoves.map { move, score in
            (move, score + Int.random(in: -profile.randomness...profile.randomness))
        }

        return randomizedMoves.max(by: { $0.1 < $1.1 })?.0
    }

    private static func negamax(
        game: GameState,
        depth: Int,
        alpha: Int,
        beta: Int,
        maximizingColor: PieceColor
    ) -> Int {
        if depth == 0 || game.status.isGameOver {
            return terminalOrEvaluationScore(for: game, maximizingColor: maximizingColor)
        }

        let moves = game.allLegalMoves(for: game.currentTurn)
        if moves.isEmpty {
            var terminalState = game
            terminalState.updateStatus()
            return terminalOrEvaluationScore(for: terminalState, maximizingColor: maximizingColor)
        }

        var bestScore = -100_000
        var alpha = alpha
        let orderedMoves = moves.sorted { lhs, rhs in
            heuristicScore(for: lhs, in: game) > heuristicScore(for: rhs, in: game)
        }

        for move in orderedMoves {
            var nextGame = game
            nextGame.applyMove(move)
            let score = -negamax(
                game: nextGame,
                depth: depth - 1,
                alpha: -beta,
                beta: -alpha,
                maximizingColor: maximizingColor
            )
            bestScore = max(bestScore, score)
            alpha = max(alpha, score)
            if alpha >= beta {
                break
            }
        }

        return bestScore
    }

    private static func terminalOrEvaluationScore(
        for game: GameState,
        maximizingColor: PieceColor
    ) -> Int {
        switch game.status {
        case .checkmate(let winner):
            return winner == maximizingColor ? 50_000 : -50_000
        case .stalemate:
            return 0
        case .playing, .check:
            return evaluateBoard(game, for: maximizingColor)
        }
    }

    private static func evaluateBoard(_ game: GameState, for maximizingColor: PieceColor) -> Int {
        var materialScore = 0
        var centerScore = 0

        for row in 0..<8 {
            for col in 0..<8 {
                guard let piece = game.board[row][col] else { continue }
                let sign = piece.color == maximizingColor ? 1 : -1
                materialScore += piece.value * 100 * sign

                let centerDist = abs(Double(row) - 3.5) + abs(Double(col) - 3.5)
                let activityBonus = Int(max(0, 4.0 - centerDist) * 8.0)
                centerScore += activityBonus * sign
            }
        }

        let mobilityBase = game.currentTurn
        let mobilityScore = game.allLegalMoves(for: mobilityBase).count * (mobilityBase == maximizingColor ? 4 : -4)
        let checkBonus: Int
        if case .check = game.status {
            checkBonus = game.currentTurn == maximizingColor ? -30 : 30
        } else {
            checkBonus = 0
        }

        return materialScore + centerScore + mobilityScore + checkBonus
    }

    private static func heuristicScore(for move: Move, in game: GameState) -> Int {
        var score = 0

        if let captured = move.captured {
            let movingValue = game.piece(at: move.from)?.value ?? 0
            score += (captured.value * 120) - (movingValue * 10)
        }

        if let promotion = move.promotion {
            score += ChessPiece(type: promotion, color: .black).value * 100
        }

        let centerDist = abs(Double(move.to.row) - 3.5) + abs(Double(move.to.col) - 3.5)
        score += Int(max(0, 4.0 - centerDist) * 10.0)

        if move.isCastling {
            score += 40
        }

        var newGame = game
        newGame.applyMove(move)
        if case .check = newGame.status {
            score += 60
        }
        if case .checkmate = newGame.status {
            score += 10_000
        }

        return score
    }
}

private struct ChessAIProfile {
    let searchDepth: Int
    let candidateCount: Int
    let randomness: Int

    init(rating: Int) {
        switch rating {
        case ..<700:
            self.searchDepth = 1
            self.candidateCount = 6
            self.randomness = 220
        case ..<900:
            self.searchDepth = 1
            self.candidateCount = 4
            self.randomness = 140
        case ..<1200:
            self.searchDepth = 2
            self.candidateCount = 3
            self.randomness = 80
        case ..<1600:
            self.searchDepth = 2
            self.candidateCount = 2
            self.randomness = 35
        default:
            self.searchDepth = 3
            self.candidateCount = 1
            self.randomness = 0
        }
    }
}

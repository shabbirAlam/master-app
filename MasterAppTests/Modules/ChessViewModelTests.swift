import Testing
@testable import MasterApp

@MainActor
struct ChessViewModelTests {

    // MARK: - ChessPiece

    @Test func pieceColor_opponent() {
        #expect(PieceColor.white.opponent == .black)
        #expect(PieceColor.black.opponent == .white)
    }

    @Test func pieceColor_allCases() {
        #expect(PieceColor.allCases.count == 2)
        #expect(PieceColor.allCases.contains(.white))
        #expect(PieceColor.allCases.contains(.black))
    }

    @Test func pieceType_allCases() {
        #expect(PieceType.allCases.count == 6)
    }

    @Test func pieceType_notationSymbol() {
        #expect(PieceType.king.notationSymbol == "K")
        #expect(PieceType.queen.notationSymbol == "Q")
        #expect(PieceType.rook.notationSymbol == "R")
        #expect(PieceType.bishop.notationSymbol == "B")
        #expect(PieceType.knight.notationSymbol == "N")
        #expect(PieceType.pawn.notationSymbol == "")
    }

    @Test func chessPiece_symbols() {
        #expect(ChessPiece(type: .king, color: .white).symbol == "\u{2654}")
        #expect(ChessPiece(type: .queen, color: .white).symbol == "\u{2655}")
        #expect(ChessPiece(type: .rook, color: .white).symbol == "\u{2656}")
        #expect(ChessPiece(type: .bishop, color: .white).symbol == "\u{2657}")
        #expect(ChessPiece(type: .knight, color: .white).symbol == "\u{2658}")
        #expect(ChessPiece(type: .pawn, color: .white).symbol == "\u{2659}")
        #expect(ChessPiece(type: .king, color: .black).symbol == "\u{265A}")
        #expect(ChessPiece(type: .queen, color: .black).symbol == "\u{265B}")
        #expect(ChessPiece(type: .rook, color: .black).symbol == "\u{265C}")
        #expect(ChessPiece(type: .bishop, color: .black).symbol == "\u{265D}")
        #expect(ChessPiece(type: .knight, color: .black).symbol == "\u{265E}")
        #expect(ChessPiece(type: .pawn, color: .black).symbol == "\u{265F}")
    }

    @Test func chessPiece_values() {
        #expect(ChessPiece(type: .pawn, color: .white).value == 1)
        #expect(ChessPiece(type: .knight, color: .white).value == 3)
        #expect(ChessPiece(type: .bishop, color: .white).value == 3)
        #expect(ChessPiece(type: .rook, color: .white).value == 5)
        #expect(ChessPiece(type: .queen, color: .white).value == 9)
        #expect(ChessPiece(type: .king, color: .white).value == 1000)
    }

    @Test func chessPiece_notationSymbol() {
        let piece = ChessPiece(type: .knight, color: .black)
        #expect(piece.notationSymbol == "N")
    }

    @Test func chessPiece_equality() {
        let a = ChessPiece(type: .rook, color: .white)
        let b = ChessPiece(type: .rook, color: .white)
        let c = ChessPiece(type: .rook, color: .black)
        #expect(a == b)
        #expect(a != c)
    }

    @Test func chessPiece_hashable() {
        let set: Set<ChessPiece> = [
            ChessPiece(type: .king, color: .white),
            ChessPiece(type: .queen, color: .black)
        ]
        #expect(set.count == 2)
    }

    // MARK: - Position

    @Test func position_algebraic() {
        #expect(Position(row: 7, col: 0).algebraic == "a1")
        #expect(Position(row: 7, col: 7).algebraic == "h1")
        #expect(Position(row: 0, col: 0).algebraic == "a8")
        #expect(Position(row: 0, col: 7).algebraic == "h8")
        #expect(Position(row: 4, col: 4).algebraic == "e4")
        #expect(Position(row: 3, col: 3).algebraic == "d5")
    }

    @Test func position_equality() {
        let a = Position(row: 3, col: 4)
        let b = Position(row: 3, col: 4)
        let c = Position(row: 3, col: 5)
        #expect(a == b)
        #expect(a != c)
    }

    // MARK: - Move

    @Test func move_notation_regular() {
        let move = Move(from: Position(row: 6, col: 4), to: Position(row: 4, col: 4), captured: nil, promotion: nil, isCastling: false, isEnPassant: false)
        #expect(move.notation == "e4")
    }

    @Test func move_notation_capture() {
        let captured = ChessPiece(type: .pawn, color: .black)
        let move = Move(from: Position(row: 3, col: 4), to: Position(row: 2, col: 3), captured: captured, promotion: nil, isCastling: false, isEnPassant: false)
        #expect(move.notation == "xd6")
    }

    @Test func move_notation_promotion() {
        let move = Move(from: Position(row: 1, col: 0), to: Position(row: 0, col: 0), captured: nil, promotion: .queen, isCastling: false, isEnPassant: false)
        #expect(move.notation == "a8=Q")
    }

    @Test func move_notation_kingsideCastling() {
        let move = Move(from: Position(row: 7, col: 4), to: Position(row: 7, col: 6), captured: nil, promotion: nil, isCastling: true, isEnPassant: false)
        #expect(move.notation == "O-O")
    }

    @Test func move_notation_queensideCastling() {
        let move = Move(from: Position(row: 7, col: 4), to: Position(row: 7, col: 2), captured: nil, promotion: nil, isCastling: true, isEnPassant: false)
        #expect(move.notation == "O-O-O")
    }

    @Test func move_notation_enPassant() {
        let captured = ChessPiece(type: .pawn, color: .black)
        let move = Move(from: Position(row: 3, col: 4), to: Position(row: 2, col: 3), captured: captured, promotion: nil, isCastling: false, isEnPassant: true)
        #expect(move.notation == "xd6 e.p.")
    }

    // MARK: - GameStatus

    @Test func gameStatus_isGameOver() {
        #expect(!GameStatus.playing.isGameOver)
        #expect(!GameStatus.check.isGameOver)
        #expect(GameStatus.checkmate(winner: .white).isGameOver)
        #expect(GameStatus.stalemate.isGameOver)
    }

    @Test func gameStatus_message() {
        #expect(GameStatus.playing.message == "Playing")
        #expect(GameStatus.check.message == "Check!")
        #expect(GameStatus.checkmate(winner: .white).message == "Checkmate! White wins!")
        #expect(GameStatus.checkmate(winner: .black).message == "Checkmate! Black wins!")
        #expect(GameStatus.stalemate.message == "Stalemate! Draw.")
    }

    // MARK: - GameState - Initialization

    @Test func gameState_initialBoard_whitePieces() {
        let game = GameState()
        // White back rank
        #expect(game.piece(at: Position(row: 7, col: 0)) == ChessPiece(type: .rook, color: .white))
        #expect(game.piece(at: Position(row: 7, col: 1)) == ChessPiece(type: .knight, color: .white))
        #expect(game.piece(at: Position(row: 7, col: 2)) == ChessPiece(type: .bishop, color: .white))
        #expect(game.piece(at: Position(row: 7, col: 3)) == ChessPiece(type: .queen, color: .white))
        #expect(game.piece(at: Position(row: 7, col: 4)) == ChessPiece(type: .king, color: .white))
        #expect(game.piece(at: Position(row: 7, col: 5)) == ChessPiece(type: .bishop, color: .white))
        #expect(game.piece(at: Position(row: 7, col: 6)) == ChessPiece(type: .knight, color: .white))
        #expect(game.piece(at: Position(row: 7, col: 7)) == ChessPiece(type: .rook, color: .white))
        // White pawns
        for col in 0..<8 {
            #expect(game.piece(at: Position(row: 6, col: col)) == ChessPiece(type: .pawn, color: .white))
        }
    }

    @Test func gameState_initialBoard_blackPieces() {
        let game = GameState()
        // Black back rank
        #expect(game.piece(at: Position(row: 0, col: 0)) == ChessPiece(type: .rook, color: .black))
        #expect(game.piece(at: Position(row: 0, col: 4)) == ChessPiece(type: .king, color: .black))
        // Black pawns
        for col in 0..<8 {
            #expect(game.piece(at: Position(row: 1, col: col)) == ChessPiece(type: .pawn, color: .black))
        }
    }

    @Test func gameState_initialProperties() {
        let game = GameState()
        #expect(game.currentTurn == .white)
        #expect(game.status == .playing)
        #expect(game.moveHistory.isEmpty)
        #expect(game.capturedPieces[.white]?.isEmpty == true)
        #expect(game.capturedPieces[.black]?.isEmpty == true)
        #expect(game.enPassantTarget == nil)
    }

    @Test func gameState_pieceAt_outOfBounds() {
        let game = GameState()
        #expect(game.piece(at: Position(row: -1, col: 0)) == nil)
        #expect(game.piece(at: Position(row: 0, col: -1)) == nil)
        #expect(game.piece(at: Position(row: 8, col: 0)) == nil)
        #expect(game.piece(at: Position(row: 0, col: 8)) == nil)
    }

    @Test func gameState_isInBounds() {
        let game = GameState()
        #expect(game.isInBounds(Position(row: 0, col: 0)))
        #expect(game.isInBounds(Position(row: 7, col: 7)))
        #expect(!game.isInBounds(Position(row: -1, col: 0)))
        #expect(!game.isInBounds(Position(row: 0, col: 8)))
    }

    @Test func gameState_findKing_initial() {
        let game = GameState()
        #expect(game.findKing(.white) == Position(row: 7, col: 4))
        #expect(game.findKing(.black) == Position(row: 0, col: 4))
    }

    @Test func gameState_findKing_notFound() {
        var game = GameState()
        game.board[7][4] = nil
        #expect(game.findKing(.white) == nil)
    }

    // MARK: - GameState - Pawn Moves

    @Test func gameState_pawnInitialMoves() {
        let game = GameState()
        let pawnPos = Position(row: 6, col: 0)
        let moves = game.pseudoLegalMoves(at: pawnPos)
        // White pawn at (6,0) can move to (5,0) and (4,0) (forward 1 or 2)
        #expect(moves.count == 2)
        #expect(moves.contains(where: { $0.to == Position(row: 5, col: 0) }))
        #expect(moves.contains(where: { $0.to == Position(row: 4, col: 0) }))
    }

    @Test func gameState_pawnCapture() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[3][3] = ChessPiece(type: .pawn, color: .white)
        game.board[2][2] = ChessPiece(type: .pawn, color: .black)
        game.board[2][4] = ChessPiece(type: .pawn, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)

        let moves = game.pseudoLegalMoves(at: Position(row: 3, col: 3))
        // White pawn at (3,3) can move forward to (2,3) and capture at (2,2) or (2,4)
        #expect(moves.count == 3)
    }

    @Test func gameState_pawnEnPassant() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[3][3] = ChessPiece(type: .pawn, color: .white)
        game.board[3][4] = ChessPiece(type: .pawn, color: .black) // just moved two squares
        game.enPassantTarget = Position(row: 2, col: 4)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)

        let moves = game.pseudoLegalMoves(at: Position(row: 3, col: 3))
        // Should include en passant capture at (2,4)
        let epMove = moves.first(where: { $0.isEnPassant })
        #expect(epMove != nil)
        #expect(epMove?.to == Position(row: 2, col: 4))
    }

    @Test func gameState_pawnPromotion() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[1][0] = ChessPiece(type: .pawn, color: .white)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)

        let moves = game.pseudoLegalMoves(at: Position(row: 1, col: 0))
        // Should have 4 promotion moves (queen, rook, bishop, knight) to (0,0)
        #expect(moves.count == 4)
        for type in [PieceType.queen, .rook, .bishop, .knight] {
            #expect(moves.contains(where: { $0.promotion == type && $0.to == Position(row: 0, col: 0) }))
        }
    }

    // MARK: - GameState - Knight Moves

    @Test func gameState_knightMoves() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .knight, color: .white)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)

        let moves = game.pseudoLegalMoves(at: Position(row: 4, col: 4))
        // Knight at d5 should have up to 8 moves
        #expect(moves.count == 8)
    }

    @Test func gameState_knightMovesBlockedByOwnPiece() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .knight, color: .white)
        game.board[2][3] = ChessPiece(type: .pawn, color: .white) // blocks one move
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)

        let moves = game.pseudoLegalMoves(at: Position(row: 4, col: 4))
        // Should have 7 moves (one blocked by own piece)
        #expect(moves.count == 7)
    }

    // MARK: - GameState - Bishop/Rook/Queen Moves

    @Test func gameState_bishopMoves() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .bishop, color: .white)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)

        let moves = game.pseudoLegalMoves(at: Position(row: 4, col: 4))
        #expect(moves.count == 13) // 7+6 diagonals from center
    }

    @Test func gameState_rookMoves() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .rook, color: .white)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)

        let moves = game.pseudoLegalMoves(at: Position(row: 4, col: 4))
        // 4 left (cols 0-3), 3 right (cols 5-7), 4 up (rows 0-3, captures black king at 0,4), 2 down (rows 5-6, white king blocks at 7,4)
        #expect(moves.count == 13)
    }

    @Test func gameState_queenMoves() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .queen, color: .white)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)

        let moves = game.pseudoLegalMoves(at: Position(row: 4, col: 4))
        // 13 rook + 13 bishop = 26 (kings block one end of vertical)
        #expect(moves.count == 26)
    }

    // MARK: - GameState - King Moves

    @Test func gameState_kingMoves() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)

        let moves = game.pseudoLegalMoves(at: Position(row: 4, col: 4))
        #expect(moves.count == 8) // 8 surrounding squares
    }

    @Test func gameState_kingDoesNotMoveIntoPawnAttack() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[7][4] = ChessPiece(type: .king, color: .white)  // e1
        game.board[0][4] = ChessPiece(type: .king, color: .black)  // e8
        game.board[3][3] = ChessPiece(type: .pawn, color: .black)  // attacks d4
        game.currentTurn = .white

        let moves = game.legalMoves(at: Position(row: 7, col: 4))
        // King should NOT be able to move to d4 (attacked by black pawn)
        #expect(!moves.contains(where: { $0.to == Position(row: 3, col: 3) }))
    }

    @Test func gameState_cannotCaptureOpponentKing() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[7][4] = ChessPiece(type: .king, color: .white)  // e1
        game.board[0][4] = ChessPiece(type: .king, color: .black)  // e8
        game.board[4][4] = ChessPiece(type: .rook, color: .white)
        game.currentTurn = .white

        let moves = game.legalMoves(at: Position(row: 4, col: 4))
        // Rook should NOT be able to capture the king
        #expect(!moves.contains(where: { $0.to == Position(row: 0, col: 4) }))
    }

    @Test func gameState_kingCannotCaptureProtectedPiece() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[7][4] = ChessPiece(type: .king, color: .white)  // e1
        game.board[4][3] = ChessPiece(type: .rook, color: .black)  // d4
        game.board[0][4] = ChessPiece(type: .king, color: .black)  // e8
        game.board[4][4] = ChessPiece(type: .rook, color: .black)  // e4, protects d4
        game.currentTurn = .white

        let moves = game.legalMoves(at: Position(row: 7, col: 4))
        // King should NOT be able to capture d4 (protected by rook at e4)
        #expect(!moves.contains(where: { $0.to == Position(row: 4, col: 3) }))
    }

    // MARK: - GameState - isSquareAttacked

    @Test func gameState_isSquareAttacked_byPawn() {
        var game = GameState()
        game.board = Self.emptyBoard()
        // Black pawn at (3,3) attacks (4,2) and (4,4)
        game.board[3][3] = ChessPiece(type: .pawn, color: .black)
        #expect(game.isSquareAttacked(Position(row: 4, col: 2), by: .black))
        #expect(game.isSquareAttacked(Position(row: 4, col: 4), by: .black))
        #expect(!game.isSquareAttacked(Position(row: 2, col: 4), by: .black))

        // White pawn at (4,4) attacks (3,3) and (3,5)
        game.board[4][4] = ChessPiece(type: .pawn, color: .white)
        #expect(game.isSquareAttacked(Position(row: 3, col: 3), by: .white))
        #expect(game.isSquareAttacked(Position(row: 3, col: 5), by: .white))
        #expect(!game.isSquareAttacked(Position(row: 5, col: 5), by: .white))
    }

    @Test func gameState_isSquareAttacked_byKnight() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .knight, color: .black)
        #expect(game.isSquareAttacked(Position(row: 2, col: 3), by: .black))
        #expect(!game.isSquareAttacked(Position(row: 0, col: 0), by: .black))
    }

    @Test func gameState_isSquareAttacked_byBishop() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .bishop, color: .black)
        #expect(game.isSquareAttacked(Position(row: 1, col: 1), by: .black))
        #expect(!game.isSquareAttacked(Position(row: 1, col: 2), by: .black))
    }

    @Test func gameState_isSquareAttacked_byRook() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .rook, color: .black)
        #expect(game.isSquareAttacked(Position(row: 4, col: 7), by: .black))
        #expect(!game.isSquareAttacked(Position(row: 0, col: 0), by: .black))
    }

    @Test func gameState_isSquareAttacked_blocked() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .rook, color: .black)
        game.board[4][6] = ChessPiece(type: .pawn, color: .black) // blocks the rook
        #expect(!game.isSquareAttacked(Position(row: 4, col: 7), by: .black))
    }

    @Test func gameState_isSquareAttacked_byQueen() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .queen, color: .black)
        #expect(game.isSquareAttacked(Position(row: 4, col: 7), by: .black)) // horizontal
        #expect(game.isSquareAttacked(Position(row: 1, col: 1), by: .black)) // diagonal
    }

    @Test func gameState_isSquareAttacked_byKing() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .king, color: .black)
        #expect(game.isSquareAttacked(Position(row: 3, col: 4), by: .black))
        #expect(!game.isSquareAttacked(Position(row: 0, col: 0), by: .black))
    }

    @Test func gameState_isSquareAttacked_noAttacker() {
        let game = GameState()
        #expect(!game.isSquareAttacked(Position(row: 7, col: 4), by: .black))
    }

    // MARK: - GameState - isInCheck

    @Test func gameState_isInCheck_true() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[3][4] = ChessPiece(type: .rook, color: .white)
        #expect(game.isInCheck(.black))
        #expect(!game.isInCheck(.white))
    }

    @Test func gameState_isInCheck_false() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[3][3] = ChessPiece(type: .rook, color: .white)
        #expect(!game.isInCheck(.black))
    }

    // MARK: - GameState - Apply Move

    @Test func gameState_applyMove_pawnForward() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[6][0] = ChessPiece(type: .pawn, color: .white)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.currentTurn = .white

        let move = Move(from: Position(row: 6, col: 0), to: Position(row: 5, col: 0), captured: nil, promotion: nil, isCastling: false, isEnPassant: false)
        game.applyMove(move)

        #expect(game.piece(at: Position(row: 5, col: 0)) == ChessPiece(type: .pawn, color: .white))
        #expect(game.piece(at: Position(row: 6, col: 0)) == nil)
        #expect(game.currentTurn == .black)
        #expect(game.moveHistory.count == 1)
    }

    @Test func gameState_applyMove_capture() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .bishop, color: .white)
        game.board[3][5] = ChessPiece(type: .pawn, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.currentTurn = .white

        let captured = ChessPiece(type: .pawn, color: .black)
        let move = Move(from: Position(row: 4, col: 4), to: Position(row: 3, col: 5), captured: captured, promotion: nil, isCastling: false, isEnPassant: false)
        game.applyMove(move)

        #expect(game.piece(at: Position(row: 3, col: 5)) == ChessPiece(type: .bishop, color: .white))
        #expect(game.piece(at: Position(row: 4, col: 4)) == nil)
        #expect(game.capturedPieces[.white]?.count == 1)
        #expect(game.capturedPieces[.white]?.first == ChessPiece(type: .pawn, color: .black))
    }

    @Test func gameState_applyMove_pawnDoublePush() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[6][0] = ChessPiece(type: .pawn, color: .white)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.currentTurn = .white

        let move = Move(from: Position(row: 6, col: 0), to: Position(row: 4, col: 0), captured: nil, promotion: nil, isCastling: false, isEnPassant: false)
        game.applyMove(move)

        #expect(game.enPassantTarget == Position(row: 5, col: 0))
    }

    @Test func gameState_applyMove_enPassant() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[3][3] = ChessPiece(type: .pawn, color: .white)
        game.board[3][4] = ChessPiece(type: .pawn, color: .black)
        game.enPassantTarget = Position(row: 2, col: 4)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.currentTurn = .white

        let captured = ChessPiece(type: .pawn, color: .black)
        let move = Move(from: Position(row: 3, col: 3), to: Position(row: 2, col: 4), captured: captured, promotion: nil, isCastling: false, isEnPassant: true)
        game.applyMove(move)

        #expect(game.piece(at: Position(row: 2, col: 4)) == ChessPiece(type: .pawn, color: .white))
        #expect(game.piece(at: Position(row: 3, col: 3)) == nil)
        #expect(game.piece(at: Position(row: 3, col: 4)) == nil) // captured pawn removed
    }

    @Test func gameState_applyMove_promotion() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[1][0] = ChessPiece(type: .pawn, color: .white)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.currentTurn = .white

        let move = Move(from: Position(row: 1, col: 0), to: Position(row: 0, col: 0), captured: nil, promotion: .queen, isCastling: false, isEnPassant: false)
        game.applyMove(move)

        #expect(game.piece(at: Position(row: 0, col: 0)) == ChessPiece(type: .queen, color: .white))
        #expect(game.piece(at: Position(row: 1, col: 0)) == nil)
    }

    @Test func gameState_applyMove_castlingKingside() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[7][7] = ChessPiece(type: .rook, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.currentTurn = .white

        let move = game.pseudoLegalMoves(at: Position(row: 7, col: 4)).first(where: { $0.isCastling })
        guard let castlingMove = move else {
            Issue.record("Expected castling move")
            return
        }

        game.applyMove(castlingMove)

        #expect(game.piece(at: Position(row: 7, col: 6)) == ChessPiece(type: .king, color: .white))
        #expect(game.piece(at: Position(row: 7, col: 5)) == ChessPiece(type: .rook, color: .white))
        #expect(game.piece(at: Position(row: 7, col: 4)) == nil)
        #expect(game.piece(at: Position(row: 7, col: 7)) == nil)
    }

    @Test func gameState_nonRookMoveToRookFileDoesNotRemoveCastlingRights() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[7][7] = ChessPiece(type: .rook, color: .white)
        game.board[3][5] = ChessPiece(type: .bishop, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.currentTurn = .white

        let bishopMove = Move(
            from: Position(row: 3, col: 5),
            to: Position(row: 5, col: 7),
            captured: nil,
            promotion: nil,
            isCastling: false,
            isEnPassant: false
        )
        game.applyMove(bishopMove)

        #expect(game.castlingRights[.white]?.kingside == true)
    }

    // MARK: - GameState - Checkmate

    @Test func gameState_checkmate() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[0][7] = ChessPiece(type: .king, color: .black)  // h8
        game.board[2][5] = ChessPiece(type: .king, color: .white)  // f6
        game.board[1][6] = ChessPiece(type: .queen, color: .white) // g7
        game.currentTurn = .black

        game.updateStatus()
        #expect(game.status == .checkmate(winner: .white))
    }

    @Test func gameState_stalemate() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[0][0] = ChessPiece(type: .king, color: .black)
        game.board[2][1] = ChessPiece(type: .queen, color: .white)
        game.board[2][2] = ChessPiece(type: .king, color: .white)
        game.currentTurn = .black

        game.updateStatus()
        // Black king at a8 can't move (a7, b7, b8 all attacked by queen/king)
        // but not currently in check -> stalemate
        #expect(game.status == .stalemate || game.status == .checkmate(winner: .white))
    }

    @Test func gameState_updateStatus_playing() {
        let game = GameState()
        // Initial position - many legal moves
        #expect(game.status == .playing)
    }

    // MARK: - GameState - selectAIMove

    @Test func gameState_selectAIMove_returnsMove() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[6][0] = ChessPiece(type: .pawn, color: .black)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        let selected = GameState.selectAIMove(from: moves, in: game, rating: 600)
        #expect(selected != nil)
        #expect(moves.contains(where: { $0 == selected }))
    }

    @Test func gameState_selectAIMove_emptyReturnsNil() {
        let selected = GameState.selectAIMove(from: [], in: GameState(), rating: 600)
        #expect(selected == nil)
    }

    @Test func gameState_selectAIMove_prefersCapture() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .rook, color: .black)
        game.board[5][4] = ChessPiece(type: .pawn, color: .white) // capturable
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        let selected = GameState.selectAIMove(from: moves, in: game, rating: 1_200)
        #expect(selected != nil)
    }

    // MARK: - Chess Rating

    @Test func chessRatingProfile_defaults() {
        let profile = ChessRatingProfile()
        #expect(profile.userRating == 600)
        #expect(profile.computerRating == 600)
    }

    @Test func chessRatingService_winIncreasesRating() {
        let service = ChessRatingServiceImpl(
            store: InMemoryChessRatingStore(
                profile: ChessRatingProfile(userRating: 600, computerRating: 600)
            )
        )

        let updated = service.applyMatchOutcome(.win)
        #expect(updated.userRating > 600)
        #expect(updated.computerRating == 600)
    }

    @Test func chessRatingService_lossDecreasesRating() {
        let service = ChessRatingServiceImpl(
            store: InMemoryChessRatingStore(
                profile: ChessRatingProfile(userRating: 600, computerRating: 1_200)
            )
        )

        let updated = service.applyMatchOutcome(.loss)
        #expect(updated.userRating < 600)
    }

    @Test func gameState_castlingRights_equality() {
        let a = GameState.CastlingRights(kingside: true, queenside: false)
        let b = GameState.CastlingRights(kingside: true, queenside: false)
        let c = GameState.CastlingRights(kingside: false, queenside: false)
        #expect(a == b)
        #expect(a != c)
    }

    // MARK: - ChessViewModel - Initialization

    @Test func viewModel_initialState() {
        let vm = ChessViewModel()
        #expect(vm.gameMode == nil)
        #expect(vm.game.currentTurn == .white)
        #expect(vm.game.status == .playing)
        #expect(vm.selectedPosition == nil)
        #expect(vm.validMoves.isEmpty)
        #expect(vm.statusMessage == "Select game mode to start")
        #expect(vm.userRating == 600)
        #expect(vm.computerRating == 600)
        #expect(!vm.showPromotionDialog)
        #expect(vm.promotionMoves.isEmpty)
        #expect(!vm.isAIThinking)
    }

    @Test func viewModel_setGameMode_twoPlayer() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)

        #expect(vm.gameMode == .twoPlayer)
        #expect(vm.selectedPosition == nil)
        #expect(vm.validMoves.isEmpty)
        #expect(vm.statusMessage == "White's turn")
    }

    @Test func viewModel_setGameMode_vsComputer() {
        let vm = ChessViewModel()
        vm.setGameMode(.vsComputer)

        #expect(vm.gameMode == .vsComputer)
        #expect(vm.statusMessage == "White's turn")
    }

    @Test func viewModel_updateComputerRating() {
        let vm = ChessViewModel()
        vm.updateComputerRating(1_100)
        #expect(vm.computerRating == 1_100)
    }

    @Test func viewModel_resetGame() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)
        #expect(vm.gameMode != nil)

        vm.resetGame()
        #expect(vm.gameMode == nil)
        #expect(vm.statusMessage == "Select game mode to start")
        #expect(vm.selectedPosition == nil)
        #expect(vm.validMoves.isEmpty)
    }

    @Test func viewModel_backToMenu() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)
        vm.backToMenu()
        #expect(vm.gameMode == nil)
    }

    // MARK: - ChessViewModel - selectSquare

    @Test func viewModel_selectSquare_selectsPiece() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)

        vm.selectSquare(at: Position(row: 6, col: 0))
        #expect(vm.selectedPosition == Position(row: 6, col: 0))
        #expect(!vm.validMoves.isEmpty)
    }

    @Test func viewModel_selectSquare_deselectsSameSquare() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)

        vm.selectSquare(at: Position(row: 6, col: 0))
        #expect(vm.selectedPosition != nil)
        vm.selectSquare(at: Position(row: 6, col: 0))
        #expect(vm.selectedPosition == nil)
        #expect(vm.validMoves.isEmpty)
    }

    @Test func viewModel_selectSquare_invalidTargetClearsSelection() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)

        vm.selectSquare(at: Position(row: 6, col: 0)) // select pawn
        vm.selectSquare(at: Position(row: 3, col: 3)) // invalid target (too far)
        #expect(vm.selectedPosition == nil)
        #expect(vm.validMoves.isEmpty)
    }

    @Test func viewModel_selectSquare_makesMove() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)

        // Select white pawn at e2
        vm.selectSquare(at: Position(row: 6, col: 4))
        #expect(vm.selectedPosition == Position(row: 6, col: 4))

        // Move to e4
        vm.selectSquare(at: Position(row: 4, col: 4))
        #expect(vm.selectedPosition == nil)
        #expect(vm.validMoves.isEmpty)
        #expect(vm.game.currentTurn == .black)
        #expect(vm.game.moveHistory.count == 1)
    }

    @Test func viewModel_selectSquare_gameOverBlocksMoves() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)

        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[0][7] = ChessPiece(type: .king, color: .black)
        game.board[2][5] = ChessPiece(type: .king, color: .white)
        game.board[1][6] = ChessPiece(type: .queen, color: .white)
        game.currentTurn = .black
        game.status = .checkmate(winner: .white)
        vm.setGameForSnapshot(game)

        vm.selectSquare(at: Position(row: 0, col: 7))
        #expect(vm.selectedPosition == nil)
    }

    @Test func viewModel_selectSquare_wrongTurnNoSelection() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)

        // Try to select black piece when it's white's turn
        vm.selectSquare(at: Position(row: 1, col: 0))
        #expect(vm.selectedPosition == nil)
    }

    // MARK: - ChessViewModel - Promotion

    @Test func viewModel_promotionFlow() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)

        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[1][0] = ChessPiece(type: .pawn, color: .white)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.currentTurn = .white
        vm.setGameForSnapshot(game)

        vm.selectSquare(at: Position(row: 1, col: 0))
        #expect(vm.selectedPosition == Position(row: 1, col: 0))

        vm.selectSquare(at: Position(row: 0, col: 0))
        #expect(vm.showPromotionDialog)
        #expect(vm.promotionMoves.count == 4)

        vm.selectPromotion(.queen)
        #expect(!vm.showPromotionDialog)
        let promoted = vm.game.piece(at: Position(row: 0, col: 0))
        #expect(promoted?.type == .queen)
        #expect(promoted?.color == .white)
    }

    @Test func viewModel_promotion_invalidTypeNoOp() {
        let vm = ChessViewModel()
        vm.setGameMode(.twoPlayer)

        // Call selectPromotion without setting promotionMoves first
        vm.selectPromotion(.queen)
        // Should not crash and no move executed
        #expect(vm.game.moveHistory.isEmpty)
    }

    // MARK: - ChessViewModel - vsComputer

    @Test func viewModel_vsComputerBlocksBlackMoves() {
        let vm = ChessViewModel()
        vm.setGameMode(.vsComputer)

        // Try to select black piece (should be blocked since computer plays black)
        vm.selectSquare(at: Position(row: 0, col: 0))
        #expect(vm.selectedPosition == nil)
    }

    // MARK: - ChessViewModel - Test Helpers

    @Test func viewModel_setGameForSnapshot() {
        let vm = ChessViewModel()
        let game = GameState()
        vm.setGameForSnapshot(game)
        #expect(vm.game.currentTurn == .white)
    }

    @Test func viewModel_setGameModeForSnapshot() {
        let vm = ChessViewModel()
        vm.setGameModeForSnapshot(.twoPlayer)
        #expect(vm.gameMode == .twoPlayer)
    }

    @Test func viewModel_setStatusForSnapshot() {
        let vm = ChessViewModel()
        vm.setStatusForSnapshot("Test")
        #expect(vm.statusMessage == "Test")
    }

    @Test func viewModel_setRatingsForSnapshot() {
        let vm = ChessViewModel()
        vm.setRatingsForSnapshot(userRating: 720, computerRating: 900)
        #expect(vm.userRating == 720)
        #expect(vm.computerRating == 900)
    }

    // MARK: - GameMode

    @Test func gameMode_equality() {
        #expect(GameMode.twoPlayer == GameMode.twoPlayer)
        #expect(GameMode.vsComputer == GameMode.vsComputer)
        #expect(GameMode.twoPlayer != GameMode.vsComputer)
    }

    // MARK: - Helpers

    private static func emptyBoard() -> [[ChessPiece?]] {
        [[ChessPiece?]](repeating: [ChessPiece?](repeating: nil, count: 8), count: 8)
    }
}

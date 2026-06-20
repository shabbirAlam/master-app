import Testing
import Foundation
@testable import MasterApp

@MainActor
struct ChessAIEngineExtendedTests {
    // MARK: - selectAIMove with various scenarios

    @Test func selectAIMove_returnsMove() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[6][0] = ChessPiece(type: .pawn, color: .black)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        let selected = ChessAIEngine.selectAIMove(from: moves, in: game, rating: 600, for: .black)
        #expect(selected != nil)
        #expect(moves.contains(where: { $0 == selected }))
    }

    @Test func selectAIMove_emptyReturnsNil() {
        let selected = ChessAIEngine.selectAIMove(from: [], in: GameState(), rating: 600, for: .black)
        #expect(selected == nil)
    }

    @Test func selectAIMove_withKingInCheck() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[0][4] = ChessPiece(type: .king, color: .black)  // e8
        game.board[3][4] = ChessPiece(type: .rook, color: .white)  // e5
        game.board[7][4] = ChessPiece(type: .king, color: .white)  // e1
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        #expect(!moves.isEmpty)

        let selected = ChessAIEngine.selectAIMove(from: moves, in: game, rating: 1_000, for: .black)
        #expect(selected != nil)
        // Apply the move to verify it gets out of check
        var newGame = game
        newGame.applyMove(selected!)
        #expect(!newGame.isInCheck(.black))
    }

    @Test func selectAIMove_depth1() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[6][0] = ChessPiece(type: .pawn, color: .black)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        let selected = ChessAIEngine.selectAIMove(from: moves, in: game, rating: 600, for: .black)
        #expect(selected != nil)
    }

    @Test func selectAIMove_depth2() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .rook, color: .black)
        game.board[5][4] = ChessPiece(type: .pawn, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        let selected = ChessAIEngine.selectAIMove(from: moves, in: game, rating: 1_200, for: .black)
        #expect(selected != nil)
    }

    @Test func selectAIMove_depth3() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .rook, color: .black)
        game.board[5][4] = ChessPiece(type: .pawn, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        let selected = ChessAIEngine.selectAIMove(from: moves, in: game, rating: 1_700, for: .black)
        #expect(selected != nil)
    }

    @Test func selectAIMove_depth4() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .rook, color: .black)
        game.board[5][4] = ChessPiece(type: .pawn, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        let selected = ChessAIEngine.selectAIMove(from: moves, in: game, rating: 2_100, for: .black)
        #expect(selected != nil)
    }

    @Test func selectAIMove_depth5() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[4][4] = ChessPiece(type: .rook, color: .black)
        game.board[5][4] = ChessPiece(type: .pawn, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        let selected = ChessAIEngine.selectAIMove(from: moves, in: game, rating: 2_300, for: .black)
        #expect(selected != nil)
    }

    @Test func selectAIMove_withRandomness() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[6][0] = ChessPiece(type: .pawn, color: .black)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        let selected = ChessAIEngine.selectAIMove(from: moves, in: game, rating: 600, for: .black)
        #expect(selected != nil)
    }

    // MARK: - ChessAIProfile

    @Test func chessAIProfile_basicTiers() {
        #expect(ChessAIProfile(rating: 500).searchDepth == 1)
        #expect(ChessAIProfile(rating: 800).searchDepth == 1)
        #expect(ChessAIProfile(rating: 1_000).searchDepth == 2)
        #expect(ChessAIProfile(rating: 1_400).searchDepth == 2)
        #expect(ChessAIProfile(rating: 1_700).searchDepth == 3)
        #expect(ChessAIProfile(rating: 1_900).searchDepth == 3)
        #expect(ChessAIProfile(rating: 2_100).searchDepth == 4)
        #expect(ChessAIProfile(rating: 2_300).searchDepth == 5)
    }

    @Test func chessAIProfile_candidateCounts() {
        #expect(ChessAIProfile(rating: 500).candidateCount == 6)
        #expect(ChessAIProfile(rating: 800).candidateCount == 4)
        #expect(ChessAIProfile(rating: 1_000).candidateCount == 3)
        #expect(ChessAIProfile(rating: 1_400).candidateCount == 2)
        #expect(ChessAIProfile(rating: 1_700).candidateCount == 2)
        #expect(ChessAIProfile(rating: 1_900).candidateCount == 1)
        #expect(ChessAIProfile(rating: 2_100).candidateCount == 1)
        #expect(ChessAIProfile(rating: 2_300).candidateCount == 1)
    }

    @Test func chessAIProfile_randomnessValues() {
        #expect(ChessAIProfile(rating: 100).randomness == 220)
        #expect(ChessAIProfile(rating: 700).randomness == 140)
        #expect(ChessAIProfile(rating: 900).randomness == 80)
        #expect(ChessAIProfile(rating: 1_200).randomness == 35)
        #expect(ChessAIProfile(rating: 1_600).randomness == 0)
    }

    // MARK: - allLegalMoves

    @Test func allLegalMoves_whiteInitial() {
        let game = GameState()
        let moves = game.allLegalMoves(for: .white)
        #expect(moves.count == 20)
    }

    @Test func allLegalMoves_blackInitial() {
        let game = GameState()
        let moves = game.allLegalMoves(for: .black)
        #expect(moves.count == 20)
    }

    @Test func allLegalMoves_emptyBoardNoKings() {
        var game = GameState()
        game.board = Self.emptyBoard()
        let moves = game.allLegalMoves(for: .white)
        #expect(moves.isEmpty)
    }

    @Test func allLegalMoves_withCheckMate() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[0][7] = ChessPiece(type: .king, color: .black)  // h8
        game.board[2][5] = ChessPiece(type: .king, color: .white)  // f6
        game.board[1][6] = ChessPiece(type: .queen, color: .white) // g7
        game.currentTurn = .black

        let moves = game.allLegalMoves(for: .black)
        #expect(moves.isEmpty)
    }

    // MARK: - PieceColor opponent

    @Test func pieceColor_opponent() {
        #expect(PieceColor.white.opponent == .black)
        #expect(PieceColor.black.opponent == .white)
    }

    // MARK: - GameMode

    @Test func gameMode_equality() {
        #expect(GameMode.twoPlayer == GameMode.twoPlayer)
        #expect(GameMode.vsComputer == GameMode.vsComputer)
        #expect(GameMode.twoPlayer != GameMode.vsComputer)
    }

    // MARK: - GameState applying move

    @Test func gameState_applyMove() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[6][4] = ChessPiece(type: .pawn, color: .white)
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.currentTurn = .white

        let move = Move(from: Position(row: 6, col: 4), to: Position(row: 5, col: 4), captured: nil, promotion: nil, isCastling: false, isEnPassant: false)
        game.applyMove(move)

        #expect(game.piece(at: Position(row: 5, col: 4)) == ChessPiece(type: .pawn, color: .white))
        #expect(game.currentTurn == .black)
    }

    // MARK: - castling with AI

    @Test func selectAIMove_withCastlingOption() {
        var game = GameState()
        game.board = Self.emptyBoard()
        game.board[7][4] = ChessPiece(type: .king, color: .white)
        game.board[7][7] = ChessPiece(type: .rook, color: .white)
        game.board[0][4] = ChessPiece(type: .king, color: .black)
        game.currentTurn = .white

        let moves = game.allLegalMoves(for: .white)
        let castlingMoves = moves.filter { $0.isCastling }
        #expect(castlingMoves.count == 1)
        #expect(castlingMoves[0].to.col == 6)
    }

    // MARK: - Helpers

    private static func emptyBoard() -> [[ChessPiece?]] {
        [[ChessPiece?]](repeating: [ChessPiece?](repeating: nil, count: 8), count: 8)
    }
}
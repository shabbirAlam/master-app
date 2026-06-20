import Testing
@testable import MasterApp

@MainActor
struct ChessPuzzleTests {

    @Test func puzzle_generator_returnsValidPuzzle() {
        let puzzle = ChessPuzzleGenerator.generate(puzzleRating: 1200)
        #expect(puzzle.userMoves.count <= ChessPuzzleGenerator.maxStep)
        #expect(puzzle.aiMoves.count <= ChessPuzzleGenerator.maxStep)
        #expect(puzzle.initialState.findKing(.white) != nil)
        #expect(puzzle.initialState.findKing(.black) != nil)
    }

    @Test func puzzle_checkmate_solutionApplies() {
        // Try to generate a checkmate puzzle specifically
        let puzzle = ChessPuzzleGenerator.generate(puzzleRating: 1600, preferredType: .checkmate)
        #expect(puzzle.puzzleType == .checkmate || puzzle.userMoves.isEmpty)
        if puzzle.puzzleType == .checkmate {
            var state = puzzle.initialState
            for (i, move) in puzzle.userMoves.enumerated() {
                state.applyMove(move)
                if i < puzzle.aiMoves.count {
                    state.applyMove(puzzle.aiMoves[i])
                }
            }
            #expect(state.status.isGameOver && state.status.isCheckmate(winner: puzzle.userColor))
        }
    }

    @Test func puzzle_tactical_materialGain() {
        let puzzle = ChessPuzzleGenerator.generate(puzzleRating: 1400, preferredType: .tactical)
        #expect(puzzle.puzzleType == .tactical || puzzle.userMoves.isEmpty)
        if puzzle.puzzleType == .tactical, let target = puzzle.targetMaterialGain {
            var state = puzzle.initialState
            let before = ChessPuzzleGenerator.materialAdvantage(state, for: puzzle.userColor)
            for (i, move) in puzzle.userMoves.enumerated() {
                state.applyMove(move)
                if i < puzzle.aiMoves.count {
                    state.applyMove(puzzle.aiMoves[i])
                }
            }
            let after = ChessPuzzleGenerator.materialAdvantage(state, for: puzzle.userColor)
            #expect(after - before >= target)
        }
    }

    @Test func puzzle_viewModel_playValidation_andHints() async {
        let vm = ChessViewModel()
        // Create a synthetic puzzle where white moves e2e4 and black replies e7e5
        var state = GameState()
        state.board = Self.emptyBoard()
        state.board[7][4] = ChessPiece(type: .king, color: .white)
        state.board[0][4] = ChessPiece(type: .king, color: .black)
        state.board[6][4] = ChessPiece(type: .pawn, color: .white)
        state.board[1][4] = ChessPiece(type: .pawn, color: .black)
        state.currentTurn = .white

        let userMove = Move(from: Position(row: 6, col: 4), to: Position(row: 4, col: 4), captured: nil, promotion: nil, isCastling: false, isEnPassant: false)
        let aiMove = Move(from: Position(row: 1, col: 4), to: Position(row: 3, col: 4), captured: nil, promotion: nil, isCastling: false, isEnPassant: false)

        let puzzle = ChessPuzzle(initialState: state, userMoves: [userMove], aiMoves: [aiMove], userColor: .white, puzzleType: .tactical, puzzleRating: 600, targetMaterialGain: 0)

        vm.setCurrentPuzzleForSnapshot(puzzle)

        // Hint level cycle
        vm.showHint()
        #expect(vm.hintLevel == 1)
        #expect(vm.hintPosition == userMove.from)

        vm.showHint()
        #expect(vm.hintLevel == 2)
        #expect(vm.hintDestination == userMove.to)

        vm.showHint()
        #expect(vm.hintLevel == 3)

        // Make correct move
        vm.testExecuteMove(userMove)
        #expect(vm.puzzleState == .playing)
        #expect(vm.puzzleStepIndex == 1)
        #expect(vm.game.moveHistory.last == userMove)

        // After user move the stored AI reply should have been applied
        #expect(vm.game.moveHistory.count == 2)
    }

    @Test func puzzle_wrongMove_failsPuzzle() {
        let vm = ChessViewModel()
        var state = GameState()
        state.board = Self.emptyBoard()
        state.board[7][4] = ChessPiece(type: .king, color: .white)
        state.board[0][4] = ChessPiece(type: .king, color: .black)
        state.board[6][4] = ChessPiece(type: .pawn, color: .white)
        state.currentTurn = .white

        let correct = Move(from: Position(row: 6, col: 4), to: Position(row: 4, col: 4), captured: nil, promotion: nil, isCastling: false, isEnPassant: false)
        let wrong = Move(from: Position(row: 6, col: 4), to: Position(row: 5, col: 4), captured: nil, promotion: nil, isCastling: false, isEnPassant: false)
        let puzzle = ChessPuzzle(initialState: state, userMoves: [correct], aiMoves: [], userColor: .white, puzzleType: .tactical, puzzleRating: 600, targetMaterialGain: 0)

        vm.setCurrentPuzzleForSnapshot(puzzle)

        vm.testExecuteMove(wrong)
        #expect(vm.puzzleState == .failure)
    }

    @Test func puzzle_eloScaling_generationHonorsRating() {
        // Ensure generator returns puzzles with various ratings without crashing
        let ratings = [600, 1000, 1400, 1800, 2000]
        for r in ratings {
            let p = ChessPuzzleGenerator.generate(puzzleRating: r)
            #expect(p.puzzleRating == r)
        }
    }

    // Helpers
    private static func emptyBoard() -> [[ChessPiece?]] {
        [[ChessPiece?]](repeating: [ChessPiece?](repeating: nil, count: 8), count: 8)
    }
}

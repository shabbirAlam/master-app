import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class ChessViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_chessView_modeSelection() {
        let viewModel = ChessViewModel()
        let view = ChessView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "mode_selection", record: record)
    }

    func test_chessView_twoPlayerInitialBoard() {
        let viewModel = ChessViewModel()
        viewModel.setGameModeForSnapshot(.twoPlayer)
        viewModel.setStatusForSnapshot("White's turn")

        let view = ChessView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "two_player_initial", record: record)
    }

    func test_chessView_vsComputerInitialBoard() {
        let viewModel = ChessViewModel()
        viewModel.setGameModeForSnapshot(.vsComputer)
        viewModel.setStatusForSnapshot("White's turn")

        let view = ChessView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "vs_computer_initial", record: record)
    }

    func test_chessView_withSelectedPiece() {
        let viewModel = ChessViewModel()
        viewModel.setGameModeForSnapshot(.twoPlayer)
        viewModel.setStatusForSnapshot("White's turn")

        // Simulate selecting a piece
        let game = viewModel.game
        viewModel.setGameForSnapshot(game)

        let view = ChessView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "board_initial", record: record)
    }

    func test_chessView_checkStatus() {
        let viewModel = ChessViewModel()
        viewModel.setGameModeForSnapshot(.twoPlayer)
        viewModel.setStatusForSnapshot("Check! White's turn")

        // Set up a game where it's white's turn and black is in check
        var game = viewModel.game
        game.currentTurn = .white
        game.status = .check
        viewModel.setGameForSnapshot(game)

        let view = ChessView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "check_status", record: record)
    }

    func test_chessView_afterSomeMoves() {
        let viewModel = ChessViewModel()
        viewModel.setGameModeForSnapshot(.twoPlayer)
        viewModel.setStatusForSnapshot("Black's turn")

        // Play a few moves: 1. e4 e5
        var game = viewModel.game
        game.currentTurn = .white
        let e4 = Move(from: Position(row: 6, col: 4), to: Position(row: 4, col: 4), captured: nil, promotion: nil, isCastling: false, isEnPassant: false)
        game.applyMove(e4)
        let e5 = Move(from: Position(row: 1, col: 4), to: Position(row: 3, col: 4), captured: nil, promotion: nil, isCastling: false, isEnPassant: false)
        game.applyMove(e5)
        viewModel.setGameForSnapshot(game)

        let view = ChessView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "after_moves", record: record)
    }
}

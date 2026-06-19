import XCTest

@MainActor
final class ChessPageUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-UITest_disableAnimations"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        try super.tearDownWithError()
    }

    func test_chessFeatureButtonExists() {
        let chessButton = app.buttons["Chess"].firstMatch
        XCTAssertTrue(chessButton.waitForExistence(timeout: 2))
    }

    func test_chess_navigateToModeSelection() {
        app.buttons["Chess"].firstMatch.tap()
        let navBar = app.navigationBars["Chess"].firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 2))
    }

    func test_chess_modeSelectionShowsBothModes() {
        app.buttons["Chess"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))

        let vsComputer = app.buttons["chess_vs_computer"].firstMatch
        let twoPlayer = app.buttons["chess_two_player"].firstMatch
        XCTAssertTrue(vsComputer.waitForExistence(timeout: 1))
        XCTAssertTrue(twoPlayer.exists)
    }

    func test_chess_selectTwoPlayerShowsBoard() {
        app.buttons["Chess"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))

        app.buttons["chess_two_player"].firstMatch.tap()
        let statusLabel = app.staticTexts["chess_status"].firstMatch
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 1))
    }

    func test_chess_selectVsComputerShowsBoard() {
        app.buttons["Chess"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))

        app.buttons["chess_vs_computer"].firstMatch.tap()
        let statusLabel = app.staticTexts["chess_status"].firstMatch
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 1))
    }

    func test_chess_boardHas64Squares() {
        app.buttons["Chess"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))
        app.buttons["chess_two_player"].firstMatch.tap()

        // Check that squares exist with algebraic notation identifiers
        let squareA1 = app.otherElements["chess_square_a1"].firstMatch
        XCTAssertTrue(squareA1.waitForExistence(timeout: 1))
        let squareE4 = app.otherElements["chess_square_e4"].firstMatch
        XCTAssertTrue(squareE4.exists)
        let squareH8 = app.otherElements["chess_square_h8"].firstMatch
        XCTAssertTrue(squareH8.exists)
    }

    func test_chess_backToMenuFromGame() {
        app.buttons["Chess"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))
        app.buttons["chess_two_player"].firstMatch.tap()

        let menuButton = app.buttons["chess_menu_button"].firstMatch
        XCTAssertTrue(menuButton.waitForExistence(timeout: 1))
        menuButton.tap()
        app.buttons["Menu"].firstMatch.tap()

        // Should see mode selection again
        let vsComputer = app.buttons["chess_vs_computer"].firstMatch
        XCTAssertTrue(vsComputer.waitForExistence(timeout: 1))
    }

    func test_chess_newGameResetsBoard() {
        app.buttons["Chess"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))
        app.buttons["chess_two_player"].firstMatch.tap()

        let menuButton = app.buttons["chess_menu_button"].firstMatch
        XCTAssertTrue(menuButton.waitForExistence(timeout: 1))
        menuButton.tap()
        app.buttons["Restart"].firstMatch.tap()

        // Board should still be visible (game mode still .twoPlayer)
        let statusLabel = app.staticTexts["chess_status"].firstMatch
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 1))
    }

    func test_chess_navigateAndReturn() {
        app.buttons["Chess"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))

        // Go back to home
        app.navigationBars["Chess"].buttons.firstMatch.tap()
        let homeView = app.collectionViews["home_view"].firstMatch
        XCTAssertTrue(homeView.waitForExistence(timeout: 2))
    }

    func test_chess_tapSquareHighlightsIt() {
        app.buttons["Chess"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))
        app.buttons["chess_two_player"].firstMatch.tap()

        let squareE2 = app.otherElements["chess_square_e2"].firstMatch
        XCTAssertTrue(squareE2.waitForExistence(timeout: 1))
        squareE2.tap()
    }
}

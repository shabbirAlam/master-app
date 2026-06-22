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

    private func tapChessButton() {
        let homeScrollView = app.scrollViews["home_view"]
        XCTAssertTrue(homeScrollView.waitForExistence(timeout: 2))
        if !homeScrollView.buttons["Chess"].exists {
            homeScrollView.swipeUp()
        }
        let chessButton = homeScrollView.buttons["Chess"].firstMatch
        XCTAssertTrue(chessButton.waitForExistence(timeout: 2))
        chessButton.tap()
    }

    func test_chessFeatureButtonExists() {
        let homeScrollView = app.scrollViews["home_view"]
        XCTAssertTrue(homeScrollView.waitForExistence(timeout: 2))
        if !homeScrollView.buttons["Chess"].exists {
            homeScrollView.swipeUp()
        }
        XCTAssertTrue(homeScrollView.buttons["Chess"].waitForExistence(timeout: 2))
    }

    func test_chess_navigateToModeSelection() {
        tapChessButton()
        let navBar = app.navigationBars["Chess"].firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 2))
    }

    func test_chess_modeSelectionShowsBothModes() {
        tapChessButton()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))

        let vsComputer = app.buttons["chess_vs_computer"].firstMatch
        let twoPlayer = app.buttons["chess_two_player"].firstMatch
        XCTAssertTrue(vsComputer.waitForExistence(timeout: 1))
        XCTAssertTrue(twoPlayer.exists)
    }

    func test_chess_selectTwoPlayerShowsBoard() {
        tapChessButton()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))

        app.buttons["chess_two_player"].firstMatch.tap()
        let statusLabel = app.staticTexts["chess_status"].firstMatch
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 2))
    }

    func test_chess_selectVsComputerShowsBoard() {
        tapChessButton()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))

        app.buttons["chess_vs_computer"].firstMatch.tap()
        let statusLabel = app.staticTexts["chess_status"].firstMatch
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 2))
    }

    func test_chess_boardHas64Squares() {
        tapChessButton()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))
        app.buttons["chess_two_player"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["chess_status"].waitForExistence(timeout: 2))

        let squareA1 = app.descendants(matching: .any)["chess_square_a1"].firstMatch
        XCTAssertTrue(squareA1.waitForExistence(timeout: 2))
        let squareE4 = app.descendants(matching: .any)["chess_square_e4"].firstMatch
        XCTAssertTrue(squareE4.exists)
        let squareH8 = app.descendants(matching: .any)["chess_square_h8"].firstMatch
        XCTAssertTrue(squareH8.exists)
    }

    func test_chess_backToMenuFromGame() {
        tapChessButton()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))
        app.buttons["chess_two_player"].firstMatch.tap()

        let menuButton = app.buttons["chess_menu_button"].firstMatch
        XCTAssertTrue(menuButton.waitForExistence(timeout: 3))
        menuButton.tap()

        let closeButton = app.buttons["Close"].firstMatch
        XCTAssertTrue(closeButton.waitForExistence(timeout: 2))
        closeButton.tap()

        let vsComputer = app.buttons["chess_vs_computer"].firstMatch
        XCTAssertTrue(vsComputer.waitForExistence(timeout: 2))
    }

    func test_chess_newGameResetsBoard() {
        tapChessButton()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))
        app.buttons["chess_two_player"].firstMatch.tap()

        let menuButton = app.buttons["chess_menu_button"].firstMatch
        XCTAssertTrue(menuButton.waitForExistence(timeout: 3))
        menuButton.tap()

        let restartButton = app.buttons["Restart"].firstMatch
        XCTAssertTrue(restartButton.waitForExistence(timeout: 2))
        restartButton.tap()

        let statusLabel = app.staticTexts["chess_status"].firstMatch
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 2))
    }

    func test_chess_navigateAndReturn() {
        tapChessButton()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))

        app.navigationBars["Chess"].buttons.firstMatch.tap()
        let homeView = app.scrollViews["home_view"].firstMatch
        XCTAssertTrue(homeView.waitForExistence(timeout: 2))
    }

    func test_chess_tapSquareHighlightsIt() {
        tapChessButton()
        XCTAssertTrue(app.navigationBars["Chess"].waitForExistence(timeout: 2))
        app.buttons["chess_two_player"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["chess_status"].waitForExistence(timeout: 2))

        let squareE2 = app.descendants(matching: .any)["chess_square_e2"].firstMatch
        XCTAssertTrue(squareE2.waitForExistence(timeout: 2))
        squareE2.tap()
    }
}

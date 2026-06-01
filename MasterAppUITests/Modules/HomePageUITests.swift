import XCTest

@MainActor
final class HomePageUITests: XCTestCase {
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

    // MARK: - Home View

    func test_homeViewLoads() {
        let homeView = app.collectionViews["home_view"].firstMatch
        XCTAssertTrue(homeView.waitForExistence(timeout: 2))
    }

    func test_homeShowsAllFeatureButtons() {
        XCTAssertTrue(app.buttons["Rest API Search"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["GraphQL Search"].exists)
        XCTAssertTrue(app.buttons["Secure View"].exists)
    }

    // MARK: - Tab Navigation

    func test_tabNavigation_switchesBetweenTabs() {
        let homeTab = app.buttons["Home"].firstMatch
        let profileTab = app.buttons["Profile"].firstMatch

        XCTAssertTrue(homeTab.waitForExistence(timeout: 1))
        XCTAssertTrue(profileTab.exists)

        profileTab.tap()
        XCTAssertTrue(app.buttons["edit_profile"].waitForExistence(timeout: 1))

        homeTab.tap()
        XCTAssertTrue(app.collectionViews["home_view"].waitForExistence(timeout: 1))
    }

    // MARK: - Rest API Search (TodoView)

    func test_navigateToRestAPISearch_ShowsTodos() {
        app.buttons["Rest API Search"].firstMatch.tap()
        let navBar = app.navigationBars["Todos"].firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 2))

        let searchField = app.textFields["Search..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
    }

    func test_restAPISearch_backToHome() {
        app.buttons["Rest API Search"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Todos"].waitForExistence(timeout: 2))

        app.navigationBars["Todos"].buttons.firstMatch.tap()
        XCTAssertTrue(app.collectionViews["home_view"].waitForExistence(timeout: 2))
    }

    // MARK: - GraphQL Search (CountryView)

    func test_navigateToGraphQLSearch_ShowsCountries() {
        app.buttons["GraphQL Search"].firstMatch.tap()
        let navBar = app.navigationBars["Countries"].firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 2))

        let searchField = app.textFields["Country..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
    }

    func test_graphQLSearch_backToHome() {
        app.buttons["GraphQL Search"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Countries"].waitForExistence(timeout: 2))

        app.navigationBars["Countries"].buttons.firstMatch.tap()
        XCTAssertTrue(app.collectionViews["home_view"].waitForExistence(timeout: 2))
    }

    // MARK: - Secure View

    func test_navigateToSecureView_ShowsSecureText() {
        app.buttons["Secure View"].firstMatch.tap()
        let secureText = app.staticTexts["This is secure view"].firstMatch
        XCTAssertTrue(secureText.waitForExistence(timeout: 2))
    }

    func test_secureView_backToHome() {
        app.buttons["Secure View"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["This is secure view"].waitForExistence(timeout: 2))

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.collectionViews["home_view"].waitForExistence(timeout: 2))
    }

    // MARK: - Profile & Edit Profile

    func test_profileTab_showsEditProfileButton() {
        app.buttons["Profile"].firstMatch.tap()
        XCTAssertTrue(app.buttons["edit_profile"].waitForExistence(timeout: 1))
    }

    func test_navigateToProfileEdit_BackButton() {
        app.buttons["Profile"].firstMatch.tap()
        app.buttons["edit_profile"].firstMatch.tap()

        let backButton = app.buttons["Back"].firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 2))
    }

    func test_navigateToProfileEdit_BackToRoot() {
        app.buttons["Profile"].firstMatch.tap()
        app.buttons["edit_profile"].firstMatch.tap()

        let backToRoot = app.buttons["Back to root"].firstMatch
        XCTAssertTrue(backToRoot.waitForExistence(timeout: 2))
        backToRoot.tap()

        XCTAssertTrue(app.buttons["edit_profile"].waitForExistence(timeout: 2))
    }

    func test_profileEdit_backToProfile() {
        app.buttons["Profile"].firstMatch.tap()
        app.buttons["edit_profile"].firstMatch.tap()
        XCTAssertTrue(app.buttons["Back"].waitForExistence(timeout: 2))

        app.buttons["Back"].firstMatch.tap()
        XCTAssertTrue(app.buttons["edit_profile"].waitForExistence(timeout: 2))
    }

    // MARK: - Navigation Deep Links

    func test_navigateAndReturnForAllFeatures() {
        struct Feature { let name: String; let navTitle: String? }
        let features: [Feature] = [
            Feature(name: "Rest API Search", navTitle: "Todos"),
            Feature(name: "GraphQL Search", navTitle: "Countries"),
            Feature(name: "Secure View", navTitle: nil),
        ]

        for feature in features {
            let button = app.buttons[feature.name].firstMatch
            XCTAssertTrue(button.waitForExistence(timeout: 1))
            button.tap()

            if let title = feature.navTitle {
                XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 2))
                app.navigationBars[title].buttons.firstMatch.tap()
            } else {
                let backButton = app.navigationBars.buttons.firstMatch
                if backButton.exists {
                    backButton.tap()
                }
            }

            XCTAssertTrue(app.collectionViews["home_view"].waitForExistence(timeout: 2))
        }
    }
}

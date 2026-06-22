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
        let homeView = app.scrollViews["home_view"].firstMatch
        XCTAssertTrue(homeView.waitForExistence(timeout: 2))
    }

    func test_homeShowsAllFeatureButtons() {
        XCTAssertTrue(app.buttons["Rest API Search"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["GraphQL Search"].exists)
        XCTAssertTrue(app.buttons["Secure View"].exists)
    }

    // MARK: - Tab Navigation

    func test_tabNavigation_switchesBetweenTabs() {
        let profileTab = app.tabBars.buttons["Profile"].firstMatch
        XCTAssertTrue(profileTab.waitForExistence(timeout: 2))
        profileTab.tap()
        XCTAssertTrue(app.buttons["edit_profile"].waitForExistence(timeout: 1))

        let homeTab = app.tabBars.buttons["Home"].firstMatch
        XCTAssertTrue(homeTab.waitForExistence(timeout: 2))
        homeTab.tap()
        XCTAssertTrue(app.scrollViews["home_view"].waitForExistence(timeout: 1))
    }

    // MARK: - Rest API Search (TodoView)

    func test_navigateToRestAPISearch_ShowsTodos() {
        let restButton = app.buttons["Rest API Search"].firstMatch
        XCTAssertTrue(restButton.waitForExistence(timeout: 2))
        restButton.tap()
        let navBar = app.navigationBars["Todos"].firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 2))

        let searchField = app.textFields["todo_search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
    }

    func test_restAPISearch_backToHome() {
        let restButton = app.buttons["Rest API Search"].firstMatch
        XCTAssertTrue(restButton.waitForExistence(timeout: 2))
        restButton.tap()
        XCTAssertTrue(app.navigationBars["Todos"].waitForExistence(timeout: 2))

        app.navigationBars["Todos"].buttons.firstMatch.tap()
        XCTAssertTrue(app.scrollViews["home_view"].waitForExistence(timeout: 2))
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
        let graphQLButton = app.buttons["GraphQL Search"].firstMatch
        XCTAssertTrue(graphQLButton.waitForExistence(timeout: 2))
        graphQLButton.tap()
        XCTAssertTrue(app.navigationBars["Countries"].waitForExistence(timeout: 2))

        app.navigationBars["Countries"].buttons.firstMatch.tap()
        XCTAssertTrue(app.scrollViews["home_view"].waitForExistence(timeout: 2))
    }

    // MARK: - Secure View

    func test_navigateToSecureView_ShowsSecureText() {
        let secureButton = app.buttons["Secure View"].firstMatch
        XCTAssertTrue(secureButton.waitForExistence(timeout: 2))
        secureButton.tap()
        let secureText = app.staticTexts["This is secure view"].firstMatch
        XCTAssertTrue(secureText.waitForExistence(timeout: 2))
    }

    func test_secureView_backToHome() {
        let secureButton = app.buttons["Secure View"].firstMatch
        XCTAssertTrue(secureButton.waitForExistence(timeout: 2))
        secureButton.tap()
        XCTAssertTrue(app.staticTexts["This is secure view"].waitForExistence(timeout: 2))

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.scrollViews["home_view"].waitForExistence(timeout: 2))
    }

    // MARK: - Profile & Edit Profile

    func test_profileTab_showsEditProfileButton() {
        let profileTab = app.tabBars.buttons["Profile"].firstMatch
        XCTAssertTrue(profileTab.waitForExistence(timeout: 2))
        profileTab.tap()
        XCTAssertTrue(app.buttons["edit_profile"].waitForExistence(timeout: 1))
    }

    func test_navigateToProfileEdit_BackButton() {
        let profileTab = app.tabBars.buttons["Profile"].firstMatch
        XCTAssertTrue(profileTab.waitForExistence(timeout: 2))
        profileTab.tap()
        app.buttons["edit_profile"].firstMatch.tap()

        let backButton = app.buttons["back_button"].firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 2))
    }

    func test_navigateToProfileEdit_BackToRoot() {
        let profileTab = app.tabBars.buttons["Profile"].firstMatch
        XCTAssertTrue(profileTab.waitForExistence(timeout: 2))
        profileTab.tap()
        app.buttons["edit_profile"].firstMatch.tap()

        let backToRoot = app.buttons["back_to_root"].firstMatch
        XCTAssertTrue(backToRoot.waitForExistence(timeout: 2))
        backToRoot.tap()
        XCTAssertTrue(app.buttons["edit_profile"].waitForExistence(timeout: 2))
    }

    func test_profileEdit_backToProfile() {
        let profileTab = app.tabBars.buttons["Profile"].firstMatch
        XCTAssertTrue(profileTab.waitForExistence(timeout: 2))
        profileTab.tap()
        app.buttons["edit_profile"].firstMatch.tap()
        XCTAssertTrue(app.buttons["back_button"].waitForExistence(timeout: 2))

        app.buttons["back_button"].firstMatch.tap()
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
            XCTAssertTrue(button.waitForExistence(timeout: 2))
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

            XCTAssertTrue(app.scrollViews["home_view"].waitForExistence(timeout: 2))
        }
    }
}

import XCTest

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
    
    func test_homeViewShows() {
        let homeView = app.collectionViews["home_view"].firstMatch
        XCTAssertTrue(homeView.waitForExistence(timeout: 2))
    }
    
    func test_homeShowsFeatureButtons() {
        let restAPISearch = app.buttons["Rest API Search"].firstMatch
        let graphQLSearch = app.buttons["GraphQL Search"].firstMatch
        let secureView = app.buttons["Secure View"].firstMatch
        
        XCTAssertTrue(restAPISearch.waitForExistence(timeout: 1))
        XCTAssertTrue(graphQLSearch.exists)
        XCTAssertTrue(secureView.exists)
    }
    
    func test_tabNavigation() {
        let homeTab = app.buttons["Home"].firstMatch
        let profileTab = app.buttons["Profile"].firstMatch
        
        XCTAssertTrue(homeTab.waitForExistence(timeout: 1))
        XCTAssertTrue(profileTab.exists)
        
        profileTab.tap()
        let editProfile = app.buttons["edit_profile"].firstMatch
        XCTAssertTrue(editProfile.waitForExistence(timeout: 1))
        
        homeTab.tap()
        let homeView = app.collectionViews["home_view"].firstMatch
        XCTAssertTrue(homeView.waitForExistence(timeout: 1))
    }
    
    func test_navigateToRestAPISearch() {
        let restAPISearch = app.buttons["Rest API Search"].firstMatch
        XCTAssertTrue(restAPISearch.waitForExistence(timeout: 1))
        restAPISearch.tap()
        
        let navBar = app.navigationBars["Todos"].firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 2))
    }
    
    func test_navigateToGraphQLSearch() {
        let graphQLSearch = app.buttons["GraphQL Search"].firstMatch
        XCTAssertTrue(graphQLSearch.waitForExistence(timeout: 1))
        graphQLSearch.tap()
        
        let navBar = app.navigationBars["Countries"].firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 2))
    }
    
    func test_navigateToSecureView() {
        let secureView = app.buttons["Secure View"].firstMatch
        XCTAssertTrue(secureView.waitForExistence(timeout: 1))
        secureView.tap()
        
        let secureText = app.staticTexts["This is secure view"].firstMatch
        XCTAssertTrue(secureText.waitForExistence(timeout: 2))
    }
    
    func test_navigateToProfileEdit() {
        let profileTab = app.buttons["Profile"].firstMatch
        XCTAssertTrue(profileTab.waitForExistence(timeout: 1))
        profileTab.tap()
        
        let editProfile = app.buttons["edit_profile"].firstMatch
        XCTAssertTrue(editProfile.waitForExistence(timeout: 1))
        editProfile.tap()
        
        let backButton = app.buttons["Back"].firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 2))
    }
}

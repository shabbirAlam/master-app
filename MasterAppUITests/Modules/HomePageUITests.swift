//
//  HomePageUITests.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

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
    
    func test_showsUserList() {
        let homeView = app.collectionViews["home_view"].firstMatch
        XCTAssertTrue(homeView.waitForExistence(timeout: 1))
        let todoButton = app.buttons["Todo"].firstMatch
        XCTAssertTrue(todoButton.exists)
    }
    
    func test_showsTodoList() {
        let todoButton = app.buttons["Todo"].firstMatch
        todoButton.tap()
        
        let lbl = app.staticTexts["todo_label"].firstMatch
        XCTAssertTrue(lbl.waitForExistence(timeout: 1))
        let backBtn = app.buttons["BackButton"].firstMatch
        XCTAssertTrue(backBtn.exists)
        backBtn.tap()
        
        XCTAssertTrue(todoButton.waitForExistence(timeout: 1))
    }
    
    func test_tabView() {
        let home = app.buttons["Home"].firstMatch
        let shorts = app.buttons["Shorts"].firstMatch
        let profile = app.buttons["Profile"].firstMatch
        
        XCTAssertTrue(home.waitForExistence(timeout: 1))
        XCTAssertTrue(shorts.exists)
        XCTAssertTrue(profile.exists)
        
        shorts.tap()
        let videoView = app.otherElements["video_0"].firstMatch
        XCTAssertTrue(videoView.waitForExistence(timeout: 1))
        
        profile.tap()
        let profileView = app.buttons["edit_profile"].firstMatch
        XCTAssertTrue(profileView.waitForExistence(timeout: 1))
        
        home.tap()
        let homeView = app.collectionViews["home_view"].firstMatch
        XCTAssertTrue(homeView.waitForExistence(timeout: 1))
    }
}

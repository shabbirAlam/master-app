//
//  MasterAppUITests.swift
//  MasterAppUITests
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import XCTest

final class MasterAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

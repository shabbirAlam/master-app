//
//  HomeViewSnapshotTests.swift
//  MasterAppTests
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

final class HomeViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never
    
    func test_homeView_snapshot() {
        let view = DashboardView()
            .environmentObject(Router())
            .environmentObject(ThemeManager())
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13),
            record: record)
    }
}

import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class DashboardViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_dashboardView_darkMode() {
        let view = DashboardView()
            .environment(Router())
            .environment(AppDIContainer())
            .preferredColorScheme(.dark)

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13),
            named: "dark",
            record: record)
    }

    func test_dashboardView_dynamicTypeLarge() {
        let view = DashboardView()
            .environment(Router())
            .environment(AppDIContainer())
            .dynamicTypeSize(.accessibility3)

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13),
            named: "large_text",
            record: record)
    }

    func test_dashboardView_iPhoneSE() {
        let view = DashboardView()
            .environment(Router())
            .environment(AppDIContainer())

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(
            of: vc,
            as: .image(on: .iPhoneSe),
            named: "iPhoneSE",
            record: record)
    }
}
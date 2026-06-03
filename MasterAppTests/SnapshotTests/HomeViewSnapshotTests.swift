import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class HomeViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_homeView_snapshot() {
        let view = DashboardView()
            .environment(Router())
            .environment(AppDIContainer())

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13),
            named: "light",
            record: record)
    }
}

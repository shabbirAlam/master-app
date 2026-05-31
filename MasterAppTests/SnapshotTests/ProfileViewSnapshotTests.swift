import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class ProfileViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_profileView() {
        let view = ProfileView()
            .environmentObject(Router())

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "light", record: record)
    }
}

@MainActor
final class ProfileDetailsViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_profileDetailsView() {
        let view = ProfileDetailsView()
            .environmentObject(Router())

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "light", record: record)
    }
}

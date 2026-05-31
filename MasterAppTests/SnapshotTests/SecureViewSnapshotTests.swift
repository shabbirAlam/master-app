import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class SecureViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_secureView() {
        let view = SecureView()

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "light", record: record)
    }
}

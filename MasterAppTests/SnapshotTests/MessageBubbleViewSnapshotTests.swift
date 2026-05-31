import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class MessageBubbleViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_userMessage() {
        let message = ChatMessage(role: .user, content: "Hello, how are you today?")
        let view = MessageBubbleView(message: message)
            .padding()

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "user", record: record)
    }

    func test_assistantMessage() {
        let message = ChatMessage(role: .assistant, content: "I'm doing great! How can I help you?")
        let view = MessageBubbleView(message: message)
            .padding()

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "assistant", record: record)
    }

    func test_longMessage() {
        let message = ChatMessage(
            role: .assistant,
            content: "This is a much longer message that should span multiple lines to test how the bubble handles longer content in the chat interface."
        )
        let view = MessageBubbleView(message: message)
            .padding()

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "long", record: record)
    }
}

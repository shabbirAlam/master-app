import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class MessageBubbleViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .all

    private let fixedDate: Date = {
        let df = ISO8601DateFormatter()
        df.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return df.date(from: "2026-05-31T12:00:00.000Z") ?? Date()
    }()

    /// MarkdownTextView uses native SwiftUI Markdown rendering (in-process),
    /// so snapshots now capture the real styled output including Markdown formatting.

    func test_userMessage() {
        let message = ChatMessage(
            role: .user, content: "Hello, how are you today?",
            timestamp: fixedDate
        )
        let vc = UIHostingController(rootView: MessageBubbleView(message: message))
        vc.view.frame = UIScreen.main.bounds
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "user", record: record)
    }

    func test_assistantMessage() {
        let message = ChatMessage(
            role: .assistant, content: "I'm doing great! How can I help you?",
            timestamp: fixedDate
        )
        let vc = UIHostingController(rootView: MessageBubbleView(message: message))
        vc.view.frame = UIScreen.main.bounds
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "assistant", record: record)
    }

    func test_longMessage() {
        let message = ChatMessage(
            role: .assistant,
            content: "This is a much longer message that should span multiple lines to test how the bubble handles longer content in the chat interface.",
            timestamp: fixedDate
        )
        let vc = UIHostingController(rootView: MessageBubbleView(message: message))
        vc.view.frame = UIScreen.main.bounds
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "long", record: record)
    }

    func test_markdownContent() {
        let message = ChatMessage(
            role: .assistant,
            content: """
            **Bold** and *italic* text.
            `inline code`
            > A blockquote
            - List item 1
            - List item 2
            """,
            timestamp: fixedDate
        )
        let vc = UIHostingController(rootView: MessageBubbleView(message: message))
        vc.view.frame = UIScreen.main.bounds
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "markdown", record: record)
    }
}

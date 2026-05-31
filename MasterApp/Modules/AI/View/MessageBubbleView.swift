import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    private let themeManager = ThemeManager.shared

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 60)
            }

            Text(message.content)
                .padding(12)
                .foregroundColor(message.role == .user ? .white : themeManager.textPrimary)
                .background(message.role == .user ? Color.blue : Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .textSelection(.enabled)

            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
    }
}

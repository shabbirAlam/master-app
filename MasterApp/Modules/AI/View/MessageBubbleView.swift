import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    private let themeManager = ThemeManager.shared

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if isUser {
                Spacer(minLength: 48)
            } else {
                assistantAvatar
            }

            VStack(alignment: .leading, spacing: 3) {
                MarkdownTextView(content: message.content, isUser: isUser)

                timestampView
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(isUser ? Color.blue : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)

            if isUser {
                userAvatar
            } else {
                Spacer(minLength: 48)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
    }

    @ViewBuilder
    private var assistantAvatar: some View {
        Image(systemName: "brain.head.profile")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(Circle().fill(Color.gray.opacity(0.45)))
    }

    @ViewBuilder
    private var userAvatar: some View {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 24))
            .foregroundColor(.gray.opacity(0.4))
    }

    @ViewBuilder
    private var timestampView: some View {
        Text(message.timestamp, style: .time)
            .font(.caption2)
            .foregroundColor(isUser ? .white.opacity(0.55) : .secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 2)
    }
}

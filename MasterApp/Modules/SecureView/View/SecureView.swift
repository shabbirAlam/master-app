import SwiftUI

struct SecureView: View {
    @State private var viewModel: SecureViewModel
    private let theme: Theme

    init(viewModel: SecureViewModel, theme: Theme) {
        self.viewModel = viewModel
        self.theme = theme
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(theme.accent)
                    .symbolVariant(.fill)
                    .symbolRenderingMode(.hierarchical)

                Text(viewModel.content.message)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(theme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(theme.background)
                    .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(theme.accent.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .secure()
        }
        .accessibilityIdentifier("secure_view")
    }
}

#Preview {
    SecureView(
        viewModel: SecureViewModel(),
        theme: AppTheme.light
    )
}

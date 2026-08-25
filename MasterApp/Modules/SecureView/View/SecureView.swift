import SwiftUI

/// Demo screen whose content is wrapped in a snapshot-preventing container,
/// hiding it from screenshots and the app switcher.
struct SecureView: View {
    /// Presentation state for the screen.
    @State private var viewModel: SecureViewModel
    /// The active design-system theme.
    private let theme: Theme

    /// Creates the view.
    /// - Parameters:
    ///   - viewModel: The injected view model.
    ///   - theme: The theme used for styling.
    init(viewModel: SecureViewModel, theme: Theme) {
        self.viewModel = viewModel
        self.theme = theme
    }

    /// Renders the protected content card inside a secure container.
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

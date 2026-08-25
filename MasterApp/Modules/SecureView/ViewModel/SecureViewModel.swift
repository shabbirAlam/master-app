import Foundation
import Observation

/// Presentation state for the secure view demo screen.
@MainActor
@Observable
final class SecureViewModel {
    /// The protected content to display.
    private(set) var content: SecureContent
    /// Whether a loading operation is in flight.
    private(set) var isLoading = false
    /// User-facing error message, or `nil` when no error occurred.
    private(set) var errorMessage: String?

    /// Creates a view model with the given content.
    /// - Parameter content: The secure content (defaults to a demo message).
    init(content: SecureContent = SecureContent(message: "This is secure view")) {
        self.content = content
        AppLogger.viewModel.log("SecureViewModel initialized", .info)
    }
}

// MARK: - Test Helpers
extension SecureViewModel {
    /// Forces the loading state for previews and snapshot tests.
    func setLoadingForSnapshot(_ loading: Bool) {
        isLoading = loading
    }

    /// Forces the error state for previews and snapshot tests.
    func setErrorForSnapshot(_ message: String?) {
        errorMessage = message
    }
}

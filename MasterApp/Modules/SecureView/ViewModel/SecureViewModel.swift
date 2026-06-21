import Foundation
import Observation

@MainActor
@Observable
final class SecureViewModel {
    private(set) var content: SecureContent
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(content: SecureContent = SecureContent(message: "This is secure view")) {
        self.content = content
        AppLogger.viewModel.log("SecureViewModel initialized", .info)
    }
}

// MARK: - Test Helpers
extension SecureViewModel {
    func setLoadingForSnapshot(_ loading: Bool) {
        isLoading = loading
    }

    func setErrorForSnapshot(_ message: String?) {
        errorMessage = message
    }
}

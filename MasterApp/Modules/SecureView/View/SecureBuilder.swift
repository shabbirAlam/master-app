import SwiftUI

/// Assembles the secure view feature from container dependencies.
enum SecureBuilder {
    /// Builds a fully wired `SecureView`.
    /// - Parameter container: The dependency container to resolve theme from.
    /// - Returns: A configured secure view.
    static func build(container: AppDIContainer) -> SecureView {
        SecureView(
            viewModel: SecureViewModel(),
            theme: container.theme
        )
    }
}

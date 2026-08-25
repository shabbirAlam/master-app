import SwiftUI

/// Assembles the home feature list from container dependencies.
enum HomeBuilder {
    /// Builds a fully wired `HomeView`.
    /// - Parameter container: The dependency container to resolve theme from.
    /// - Returns: A configured home view.
    static func build(container: AppDIContainer) -> HomeView {
        let viewModel = HomeViewModel(
            features: HomeFeatures.allCases,
            theme: container.theme
        )
        return HomeView(viewModel: viewModel)
    }
}

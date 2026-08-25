import SwiftUI

/// Assembles the country search feature from container dependencies.
enum CountryBuilder {
    /// Builds a fully wired `CountryView`.
    /// - Parameter container: The dependency container to resolve services from.
    /// - Returns: A configured country search view.
    static func build(container: AppDIContainer) -> CountryView {
        let viewModel = CountryViewModel(
            service: CountryServiceImpl(
                repository: CountryRepositoryImpl(
                    networking:
                        container.graphQLNetworking)))
        return CountryView(viewModel: viewModel, theme: container.theme)
    }
}

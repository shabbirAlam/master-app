import SwiftUI

enum CountryBuilder {
    static func build(container: AppDIContainer = AppDIContainer()) -> CountryView {
        let viewModel = CountryViewModel(
            service: CountryServiceImpl(
                repository: CountryRepositoryImpl(
                    networking:
                        container.graphQLNetworking)))
        return CountryView(viewModel: viewModel, theme: container.theme)
    }
}

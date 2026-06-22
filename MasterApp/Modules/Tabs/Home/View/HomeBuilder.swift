import SwiftUI

enum HomeBuilder {
    static func build(container: AppDIContainer) -> HomeView {
        let viewModel = HomeViewModel(
            features: HomeFeatures.allCases,
            theme: container.theme
        )
        return HomeView(viewModel: viewModel)
    }
}

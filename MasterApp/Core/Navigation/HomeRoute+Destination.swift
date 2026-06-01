import SwiftUI

extension HomeRoute {
    @ViewBuilder
    func destination(container: AppDIContainer) -> some View {
        switch self {
        case .secureView:
            SecureView()
        case .graphQLSearch:
            CountryBuilder.build(container: container)
        case .restAPISearch:
            TodoBuilder.build(container: container)
        }
    }
}

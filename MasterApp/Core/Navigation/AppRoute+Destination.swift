import SwiftUI

extension AppRoute {
    @ViewBuilder
    func destination(container: AppDIContainer) -> some View {
        switch self {
        case .home(let details):
            details.destination(container: container)
        case .profile(let details):
            details.destination(container: container)
        }
    }
}

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

extension ProfileRoute {
    @ViewBuilder
    func destination(container: AppDIContainer) -> some View {
        switch self {
        case .editProfile:
            ProfileView()
        }
    }
}

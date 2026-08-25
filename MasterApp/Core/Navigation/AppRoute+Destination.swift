import SwiftUI

extension AppRoute {
    /// Builds the destination view for this route.
    ///
    /// - Parameter container: The dependency container used to construct the destination.
    /// - Returns: The view representing the route's destination.
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
    /// Builds the destination view for this home-tab route.
    ///
    /// - Parameter container: The dependency container used to construct the destination.
    /// - Returns: The feature view associated with the route.
    @ViewBuilder
    func destination(container: AppDIContainer) -> some View {
        switch self {
        case .secureView:
            SecureBuilder.build(container: container)
        case .graphQLSearch:
            CountryBuilder.build(container: container)
        case .restAPISearch:
            TodoBuilder.build(container: container)
        case .chess:
            ChessBuilder.build(container: container)
        }
    }
}

extension ProfileRoute {
    /// Builds the destination view for this profile-tab route.
    ///
    /// - Parameter container: The dependency container used to construct the destination.
    /// - Returns: The feature view associated with the route.
    @ViewBuilder
    func destination(container: AppDIContainer) -> some View {
        switch self {
        case .editProfile:
            ProfileDetailsView()
        }
    }
}

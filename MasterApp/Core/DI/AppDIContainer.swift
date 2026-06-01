import Foundation

/// Centralized dependency container for the app.
/// All Builders resolve dependencies from this container to ensure consistent
/// configuration and to make tests easier to write and run.
@MainActor
final class AppDIContainer {
    let theme: Theme
    let networking: Networking
    let graphQLNetworking: GraphQLNetworking

    init(
        theme: Theme = AppTheme.light,
        networking: Networking = NetworkingImpl(),
        graphQLNetworking: GraphQLNetworking = GraphQLNetworkingImpl(),
    ) {
        self.theme = theme
        self.networking = networking
        self.graphQLNetworking = graphQLNetworking
    }
}

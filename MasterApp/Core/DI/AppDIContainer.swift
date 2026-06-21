import Foundation
import Observation

/// Centralized dependency container for the app.
/// All Builders resolve dependencies from this container to ensure consistent
/// configuration and to make mock and tests easier to write and run.
@MainActor
@Observable
final class AppDIContainer {
    let theme: Theme
    let networking: Networking
    let graphQLNetworking: GraphQLNetworking
    let chessRatingService: ChessRatingService
    let chessKitService: ChessKitAIService

    init(
        theme: Theme = AppTheme.light,
        networking: Networking = NetworkingImpl(),
        graphQLNetworking: GraphQLNetworking = GraphQLNetworkingImpl(),
        chessRatingService: ChessRatingService = ChessRatingServiceImpl(
            store: UserDefaultsChessRatingStore()
        ),
        chessKitService: ChessKitAIService = ChessKitAIServiceImpl()
    ) {
        self.theme = theme
        self.networking = networking
        self.graphQLNetworking = graphQLNetworking
        self.chessRatingService = chessRatingService
        self.chessKitService = chessKitService
    }
}

import Foundation
import Observation

/// Centralized dependency container for the app.
/// All Builders resolve dependencies from this container to ensure consistent
/// configuration and to make mock and tests easier to write and run.
@MainActor
@Observable
final class AppDIContainer {
    /// The active design-system theme.
    let theme: Theme
    /// REST networking client.
    let networking: Networking
    /// GraphQL networking client.
    let graphQLNetworking: GraphQLNetworking
    /// Service managing chess rating calculations and persistence.
    let chessRatingService: ChessRatingService
    /// Service wrapping the ChessKit engine for AI moves.
    let chessKitService: ChessKitAIService
    /// Repository providing access to the local puzzle database.
    let puzzleRepository: PuzzleRepository

    /// Creates a container with injectable dependencies, defaulting to
    /// production implementations suitable for runtime use.
    ///
    /// - Parameters:
    ///   - theme: The design system theme to use.
    ///   - networking: The REST networking implementation.
    ///   - graphQLNetworking: The GraphQL networking implementation.
    ///   - chessRatingService: The chess rating service.
    ///   - chessKitService: The ChessKit AI service.
    ///   - puzzleRepository: The puzzle repository.
    init(
        theme: Theme = AppTheme.light,
        networking: Networking = NetworkingImpl(),
        graphQLNetworking: GraphQLNetworking = GraphQLNetworkingImpl(),
        chessRatingService: ChessRatingService = ChessRatingServiceImpl(
            store: UserDefaultsChessRatingStore()
        ),
        chessKitService: ChessKitAIService = ChessKitAIServiceImpl(),
        puzzleRepository: PuzzleRepository = SQLitePuzzleRepository()
    ) {
        self.theme = theme
        self.networking = networking
        self.graphQLNetworking = graphQLNetworking
        self.chessRatingService = chessRatingService
        self.chessKitService = chessKitService
        self.puzzleRepository = puzzleRepository
    }
}

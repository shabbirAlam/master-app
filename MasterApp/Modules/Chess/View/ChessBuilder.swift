import SwiftUI

/// Factory for constructing the chess feature from the shared application container.
enum ChessBuilder {
    /// Builds the complete chess screen using container-resolved dependencies.
    /// - Parameter container: The shared dependency container.
    /// - Returns: A fully configured chess view.
    static func build(container: AppDIContainer) -> ChessView {
        let viewModel = ChessViewModel(
            ratingService: container.chessRatingService,
            chessKitService: container.chessKitService
        )
        return ChessView(
            viewModel: viewModel,
            puzzleRepository: container.puzzleRepository,
            theme: container.theme
        )
    }
}

import SwiftUI

enum ChessBuilder {
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

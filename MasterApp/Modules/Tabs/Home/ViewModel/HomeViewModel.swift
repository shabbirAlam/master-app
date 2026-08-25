import Foundation
import Observation

/// Presentation state for the home feature list.
@MainActor
@Observable
final class HomeViewModel {
    /// The features displayed on the home screen.
    private(set) var items: [HomeFeatures]
    /// The active design-system theme.
    let theme: Theme

    /// Creates a view model.
    /// - Parameters:
    ///   - features: The features to display.
    ///   - theme: The theme used for styling.
    init(features: [HomeFeatures], theme: Theme) {
        self.items = features
        self.theme = theme
    }

    /// Maps a home feature to its navigation route.
    /// - Parameter item: The tapped feature.
    /// - Returns: The corresponding `AppRoute`, or `nil` if unmapped.
    func route(for item: HomeFeatures) -> AppRoute? {
        switch item {
        case .secureView: return .home(type: .secureView)
        case .graphQLSearch: return .home(type: .graphQLSearch)
        case .restAPISearch: return .home(type: .restAPISearch)
        case .chess: return .home(type: .chess)
        }
    }
}

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private(set) var items: [HomeFeatures]
    let theme: Theme

    init(features: [HomeFeatures], theme: Theme) {
        self.items = features
        self.theme = theme
    }

    func route(for item: HomeFeatures) -> AppRoute? {
        switch item {
        case .secureView: return .home(type: .secureView)
        case .graphQLSearch: return .home(type: .graphQLSearch)
        case .restAPISearch: return .home(type: .restAPISearch)
        case .chess: return .home(type: .chess)
        }
    }
}

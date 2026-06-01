import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var items: [HomeFeatures]
    let theme: Theme

    init(features: [HomeFeatures] = HomeFeatures.allCases, theme: Theme = AppTheme.light) {
        self.items = features
        self.theme = theme
    }

    func route(for item: HomeFeatures) -> AppRoute? {
        switch item {
        case .secureView: return .home(type: .secureView)
        case .graphQLSearch: return .home(type: .graphQLSearch)
        case .restAPISearch: return .home(type: .restAPISearch)
        }
    }
}

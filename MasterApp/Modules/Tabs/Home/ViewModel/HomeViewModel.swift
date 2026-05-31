import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var items: [HomeFeatures] = []

    init() {
        setRows()
    }

    func setRows() {
        items = [.restAPISearch, .graphQLSearch, .secureView]
        if AIAvailability.isEnabled() {
            items.insert(.ai, at: 0)
        }
    }

    func route(for item: HomeFeatures) -> AppRoute? {
        switch item {
        case .ai: .home(type: .ai)
        case .secureView: .home(type: .secureView)
        case .graphQLSearch: .home(type: .graphQLSearch)
        case .restAPISearch: .home(type: .restAPISearch)
        }
    }
}

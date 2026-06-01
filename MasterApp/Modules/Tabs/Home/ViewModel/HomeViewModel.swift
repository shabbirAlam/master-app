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
    }

    func route(for item: HomeFeatures) -> AppRoute? {
        switch item {
        case .secureView: .home(type: .secureView)
        case .graphQLSearch: .home(type: .graphQLSearch)
        case .restAPISearch: .home(type: .restAPISearch)
        }
    }
}

import Foundation
import Observation

@Observable
final class Router {
    var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeAll()
    }

    func popTo(_ route: AppRoute) {
        guard let index = path.lastIndex(of: route) else {
            return
        }

        let elementsToRemove = path.count - (index + 1)

        guard elementsToRemove > 0 else { return }

        path.removeLast(elementsToRemove)
    }
}

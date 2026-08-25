import Foundation
import Observation

/// Type-safe navigation stack backed by an array of `AppRoute` values,
/// intended for use with `NavigationStack(path:)`.
@Observable
final class Router {
    /// The current navigation path.
    var path: [AppRoute] = []

    /// Appends a route onto the navigation stack.
    /// - Parameter route: The route to navigate to.
    func push(_ route: AppRoute) {
        path.append(route)
    }

    /// Pops the topmost route from the stack, if any.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Removes all routes, returning to the root of the stack.
    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeAll()
    }

    /// Unwinds the stack back to the most recent occurrence of the given route.
    ///
    /// Does nothing if the route is not currently on the stack or is already
    /// the topmost element.
    /// - Parameter route: The destination to unwind to.
    func popTo(_ route: AppRoute) {
        guard let index = path.lastIndex(of: route) else {
            return
        }

        let elementsToRemove = path.count - (index + 1)

        guard elementsToRemove > 0 else { return }

        path.removeLast(elementsToRemove)
    }
}

import SwiftUI

/// Assembles the todo search feature from container dependencies.
enum TodoBuilder {
    /// Builds a fully wired `TodoView`.
    /// - Parameter container: The dependency container to resolve services from.
    /// - Returns: A configured todo search view.
    static func build(container: AppDIContainer) -> TodoView {
        let viewModel = TodoViewModel(
            service: TodoServiceImpl(
                repository: TodoRepositoryImpl(
                    networking: container.networking)))
        return TodoView(viewModel: viewModel, theme: container.theme)
    }
}

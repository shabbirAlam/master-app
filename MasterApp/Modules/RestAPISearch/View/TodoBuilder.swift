import SwiftUI

enum TodoBuilder {
    static func build(container: AppDIContainer) -> TodoView {
        let viewModel = TodoViewModel(
            service: TodoServiceImpl(
                repository: TodoRepositoryImpl(
                    networking: container.networking)))
        return TodoView(viewModel: viewModel, theme: container.theme)
    }
}

import Foundation

/// Business-logic contract for todo workflows.
protocol TodoService: Sendable {
    /// Fetches all todos.
    /// - Returns: The list of todos.
    /// - Throws: Any error propagated by the repository.
    func fetchTodos() async throws -> [Todo]
}

/// Default `TodoService` delegating to a `TodoRepository`.
final class TodoServiceImpl: TodoService {
    private let repository: TodoRepository

    /// Creates a service.
    /// - Parameter repository: The todo data source.
    init(repository: TodoRepository) {
        self.repository = repository
        AppLogger.service.log("TodoServiceImpl initialized", .info)
    }

    /// Fetches all todos via the repository.
    func fetchTodos() async throws -> [Todo] {
        AppLogger.service.log("Fetching todos", .info)
        return try await repository.fetchTodos()
    }
}

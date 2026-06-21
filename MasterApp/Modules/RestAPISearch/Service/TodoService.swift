import Foundation

protocol TodoService: Sendable {
    func fetchTodos() async throws -> [Todo]
}

final class TodoServiceImpl: TodoService {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
        AppLogger.service.log("TodoServiceImpl initialized", .info)
    }

    func fetchTodos() async throws -> [Todo] {
        AppLogger.service.log("Fetching todos", .info)
        return try await repository.fetchTodos()
    }
}

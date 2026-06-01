import Foundation

protocol TodoService: Sendable {
    func fetchTodos() async throws -> [Todo]
}

final class TodoServiceImpl: TodoService {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func fetchTodos() async throws -> [Todo] {
        try await repository.fetchTodos()
    }
}

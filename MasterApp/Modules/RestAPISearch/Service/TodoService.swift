import Foundation

protocol TodoService {
    func fetchTodos() async throws -> [Todo]
}

final class TodoServiceImpl: TodoService {
    private let networking: Networking

    init(networking: Networking) {
        self.networking = networking
    }

    func fetchTodos() async throws -> [Todo] {
        try await Task.sleep(nanoseconds: 500_000_000)
        try Task.checkCancellation()
        return try await networking.request(APIEndpoint.todos)
    }
}

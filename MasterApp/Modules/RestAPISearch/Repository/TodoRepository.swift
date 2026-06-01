import Foundation

protocol TodoRepository: Sendable {
    func fetchTodos() async throws -> [Todo]
}

final class TodoRepositoryImpl: TodoRepository {
    private let networking: Networking
    private let simulatedDelayNanos: UInt64

    init(networking: Networking, simulatedDelayNanos: UInt64 = 500_000_000) {
        self.networking = networking
        self.simulatedDelayNanos = simulatedDelayNanos
    }

    func fetchTodos() async throws -> [Todo] {
        try await Task.sleep(nanoseconds: simulatedDelayNanos)
        try Task.checkCancellation()
        return try await networking.request(APIEndpoint.todos)
    }
}

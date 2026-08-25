import Foundation

/// Data access contract for todo items over REST.
protocol TodoRepository: Sendable {
    /// Fetches all todos.
    /// - Returns: The list of todos.
    /// - Throws: `NetworkError` on request or decoding failure.
    func fetchTodos() async throws -> [Todo]
}

/// Default `TodoRepository` backed by `Networking`, with a simulated delay
/// so loading states are visible in demos and previews.
final class TodoRepositoryImpl: TodoRepository {
    private let networking: Networking
    /// Artificial delay before the request, in nanoseconds.
    private let simulatedDelayNanos: UInt64

    /// Creates a repository.
    /// - Parameters:
    ///   - networking: The REST client used for data access.
    ///   - simulatedDelayNanos: Simulated latency in nanoseconds (defaults to 0.5s).
    init(networking: Networking, simulatedDelayNanos: UInt64 = 500_000_000) {
        self.networking = networking
        self.simulatedDelayNanos = simulatedDelayNanos
        AppLogger.repository.log("TodoRepositoryImpl initialized", .info)
    }

    /// Fetches all todos after a simulated delay, supporting cancellation.
    func fetchTodos() async throws -> [Todo] {
        AppLogger.repository.log("Fetching todos", .info)
        try await Task.sleep(nanoseconds: simulatedDelayNanos)
        try Task.checkCancellation()
        return try await networking.request(APIEndpoint.todos)
    }
}

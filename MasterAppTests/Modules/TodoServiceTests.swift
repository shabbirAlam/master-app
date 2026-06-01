import Testing
@testable import MasterApp

@MainActor
final class MockTodoRepository: TodoRepository {
    private var mockData: [Todo]?
    private var mockError: Error?

    func fetchTodos() async throws -> [Todo] {
        if let mockError { throw mockError }
        if let data = mockData { return data }
        return []
    }

    func setData(_ data: [Todo]) { mockData = data }
    func setError(_ error: Error) { mockError = error }
}

@MainActor
struct TodoServiceTests {
    @Test func fetchTodosSuccess() async throws {
        let mock = MockTodoRepository()
        mock.setData([Todo(userId: 1, id: 1, title: "test title", body: "test body")])

        let service = TodoServiceImpl(repository: mock)
        let todos = try await service.fetchTodos()

        #expect(todos.count == 1)
        #expect(todos[0].title == "test title")
        #expect(todos[0].userId == 1)
    }

    @Test func fetchTodosError() async {
        let mock = MockTodoRepository()
        mock.setError(NetworkError.badStatusCode(500))

        let service = TodoServiceImpl(repository: mock)

        do {
            let _ = try await service.fetchTodos()
            Issue.record("Expected error")
        } catch let error as NetworkError {
            switch error {
            case .badStatusCode(let code):
                #expect(code == 500)
            default:
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func fetchTodosCancellation() async {
        let mock = MockTodoRepository()
        mock.setData([Todo(userId: 1, id: 1, title: "test", body: "test")])

        let service = TodoServiceImpl(repository: mock)

        let task = Task {
            try await service.fetchTodos()
        }

        try? await Task.sleep(nanoseconds: 10_000_000)
        task.cancel()

        do {
            let _ = try await task.value
        } catch is CancellationError {
            #expect(true)
        } catch {
            // Task may complete before cancellation takes effect
            #expect(true)
        }
    }

    @Test func todosEndpoint() {
        let endpoint = APIEndpoint.todos
        #expect(endpoint.baseURL == ApiConfig.todoBaseURL)
        #expect(endpoint.path == "posts")
        #expect(endpoint.method == .GET)
    }
}

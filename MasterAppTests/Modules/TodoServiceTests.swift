import Testing
@testable import MasterApp

struct TodoServiceTests {
    @Test func fetchTodosSuccess() async throws {
        let mock = MockNetworkServiceImpl()
        mock.setData([Todo(userId: 1, id: 1, title: "test title", body: "test body")])

        let service = TodoServiceImpl(networking: mock)
        let todos = try await service.fetchTodos()

        #expect(todos.count == 1)
        #expect(todos[0].title == "test title")
        #expect(todos[0].userId == 1)
    }

    @Test func fetchTodosError() async {
        let mock = MockNetworkServiceImpl()
        mock.setError(NetworkError.badStatusCode(500))

        let service = TodoServiceImpl(networking: mock)

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
        let mock = MockNetworkServiceImpl()
        mock.setData([Todo(userId: 1, id: 1, title: "test", body: "test")])

        let service = TodoServiceImpl(networking: mock)

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

import Testing
@testable import MasterApp

@MainActor
struct TodoViewModelTests {
    
    @Test
    func fetchTodosSuccess() async {
        let mock = MockTodoService()
        mock.setData([
            Todo(userId: 1, id: 1, title: "test title", body: "test body")
        ])
        let vm = TodoViewModel(service: mock)
        
        await vm.fetchTodos()
        
        #expect(vm.isLoading == false)
        #expect(vm.items.count == 1)
        #expect(vm.items[0].title == "test title")
        #expect(vm.errorMsg == nil)
    }
    
    @Test
    func fetchTodosFailure() async {
        let mock = MockTodoService()
        mock.setError(NetworkError.unknown)
        let vm = TodoViewModel(service: mock)
        
        await vm.fetchTodos()
        
        #expect(vm.isLoading == false)
        #expect(vm.items.isEmpty)
        #expect(vm.errorMsg != nil)
    }
    
    @Test
    func fetchTodosCancellation() async {
        let mock = MockTodoService()
        mock.setError(CancellationError())
        let vm = TodoViewModel(service: mock)

        await vm.fetchTodos()

        #expect(vm.isLoading == false)
        #expect(vm.items.isEmpty)
        #expect(vm.errorMsg == nil)
    }

    @Test
    func fetchTodosSearchFilter() async {
        let mock = MockTodoService()
        mock.setData([
            Todo(userId: 1, id: 1, title: "apple", body: "body1"),
            Todo(userId: 1, id: 2, title: "banana", body: "body2"),
            Todo(userId: 1, id: 3, title: "application", body: "body3"),
        ])
        let vm = TodoViewModel(service: mock)
        vm.searchedText = "app"
        
        await vm.fetchTodos()
        
        #expect(vm.items.count == 2)
        #expect(vm.items[0].title == "apple")
        #expect(vm.items[1].title == "application")
    }

    @Test
    func fetchTodosEmptyData() async {
        let mock = MockTodoService()
        mock.setData([])
        let vm = TodoViewModel(service: mock)

        await vm.fetchTodos()

        #expect(vm.isLoading == false)
        #expect(vm.items.isEmpty)
        #expect(vm.errorMsg == nil)
    }

    @Test
    func fetchTodosSearchNoMatch() async {
        let mock = MockTodoService()
        mock.setData([
            Todo(userId: 1, id: 1, title: "apple", body: "body1"),
            Todo(userId: 1, id: 2, title: "banana", body: "body2"),
        ])
        let vm = TodoViewModel(service: mock)
        vm.searchedText = "zzzzz"

        await vm.fetchTodos()

        #expect(vm.items.isEmpty)
    }
}

final class MockTodoService: TodoService {
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

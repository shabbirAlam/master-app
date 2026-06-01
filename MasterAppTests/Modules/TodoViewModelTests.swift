import Testing
@testable import MasterApp

@MainActor
struct TodoViewModelTests {

    @Test
    func fetchTodosSuccess() async {
        let mock = MockTodoRepository()
        mock.setData([
            Todo(userId: 1, id: 1, title: "test title", body: "test body")
        ])
        let vm = TodoViewModel(service: TodoServiceImpl(repository: mock))

        await vm.fetchTodos()

        #expect(vm.isLoading == false)
        #expect(vm.items.count == 1)
        #expect(vm.items[0].title == "test title")
        #expect(vm.errorMessage == nil)
    }

    @Test
    func fetchTodosFailure() async {
        let mock = MockTodoRepository()
        mock.setError(NetworkError.unknown)
        let vm = TodoViewModel(service: TodoServiceImpl(repository: mock))

        await vm.fetchTodos()

        #expect(vm.isLoading == false)
        #expect(vm.items.isEmpty)
        #expect(vm.errorMessage != nil)
    }

    @Test
    func fetchTodosCancellation() async {
        let mock = MockTodoRepository()
        mock.setError(CancellationError())
        let vm = TodoViewModel(service: TodoServiceImpl(repository: mock))

        await vm.fetchTodos()

        #expect(vm.isLoading == false)
        #expect(vm.items.isEmpty)
        #expect(vm.errorMessage == nil)
    }

    @Test
    func fetchTodosSearchFilter() async {
        let mock = MockTodoRepository()
        mock.setData([
            Todo(userId: 1, id: 1, title: "apple", body: "body1"),
            Todo(userId: 1, id: 2, title: "banana", body: "body2"),
            Todo(userId: 1, id: 3, title: "application", body: "body3"),
        ])
        let vm = TodoViewModel(service: TodoServiceImpl(repository: mock))
        vm.searchedText = "app"

        await vm.fetchTodos()

        #expect(vm.items.count == 2)
        #expect(vm.items[0].title == "apple")
        #expect(vm.items[1].title == "application")
    }

    @Test
    func fetchTodosEmptyData() async {
        let mock = MockTodoRepository()
        mock.setData([])
        let vm = TodoViewModel(service: TodoServiceImpl(repository: mock))

        await vm.fetchTodos()

        #expect(vm.isLoading == false)
        #expect(vm.items.isEmpty)
        #expect(vm.errorMessage == nil)
    }

    @Test
    func fetchTodosSearchNoMatch() async {
        let mock = MockTodoRepository()
        mock.setData([
            Todo(userId: 1, id: 1, title: "apple", body: "body1"),
            Todo(userId: 1, id: 2, title: "banana", body: "body2"),
        ])
        let vm = TodoViewModel(service: TodoServiceImpl(repository: mock))
        vm.searchedText = "zzzzz"

        await vm.fetchTodos()

        #expect(vm.items.isEmpty)
    }

    @Test
    func filterSearchTriggersFiltering() async {
        let mock = MockTodoRepository()
        mock.setData([
            Todo(userId: 1, id: 1, title: "apple pie", body: "body1"),
            Todo(userId: 1, id: 2, title: "banana split", body: "body2"),
            Todo(userId: 1, id: 3, title: "apricot", body: "body3"),
        ])
        let vm = TodoViewModel(service: TodoServiceImpl(repository: mock))
        await vm.fetchTodos()
        #expect(vm.items.count == 3)

        vm.searchedText = "apple"
        vm.filterSearch()
        #expect(vm.items.count == 1)
        #expect(vm.items[0].title == "apple pie")

        vm.searchedText = ""
        vm.filterSearch()
        #expect(vm.items.count == 3)
    }

    @Test
    func fetchTodosGenericError() async {
        let mock = MockTodoRepository()
        struct SomeError: Error {}
        mock.setError(SomeError())
        let vm = TodoViewModel(service: TodoServiceImpl(repository: mock))

        await vm.fetchTodos()

        #expect(vm.isLoading == false)
        #expect(vm.items.isEmpty)
        #expect(vm.errorMessage != nil)
    }
}

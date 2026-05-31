import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class TodoViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_todoView_withData() {
        let vm = TodoViewModel(service: SnapshotMockTodoService(data: [
            Todo(userId: 1, id: 1, title: "Buy groceries", body: "Milk, eggs, bread"),
            Todo(userId: 1, id: 2, title: "Finish project", body: "Complete the report"),
        ]))
        vm.items = [
            Todo(userId: 1, id: 1, title: "Buy groceries", body: "Milk, eggs, bread"),
            Todo(userId: 1, id: 2, title: "Finish project", body: "Complete the report"),
        ]

        let view = TodoView(vm: vm)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "data", record: record)
    }

    func test_todoView_empty() {
        let vm = TodoViewModel(service: SnapshotMockTodoService(data: []))
        vm.items = []

        let view = TodoView(vm: vm)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "empty", record: record)
    }

    func test_todoView_withSearchActive() {
        let vm = TodoViewModel(service: SnapshotMockTodoService(data: [
            Todo(userId: 1, id: 1, title: "Buy groceries", body: "Milk, eggs, bread"),
            Todo(userId: 1, id: 2, title: "Finish project", body: "Complete the report"),
        ]))
        vm.items = [
            Todo(userId: 1, id: 1, title: "Buy groceries", body: "Milk, eggs, bread"),
        ]
        vm.searchedText = "groceries"

        let view = TodoView(vm: vm)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "search", record: record)
    }

    func test_todoView_loading() {
        let vm = TodoViewModel(service: SnapshotMockTodoService(data: []))
        vm.isLoading = true

        let view = TodoView(vm: vm)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "loading", record: record)
    }

    func test_todoView_error() {
        let vm = TodoViewModel(service: SnapshotMockTodoService(data: []))
        vm.errorMsg = "Something went wrong"
        vm.items = []

        let view = TodoView(vm: vm)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "error", record: record)
    }
}

private final class SnapshotMockTodoService: TodoService {
    let data: [Todo]
    init(data: [Todo]) { self.data = data }
    func fetchTodos() async throws -> [Todo] { data }
}

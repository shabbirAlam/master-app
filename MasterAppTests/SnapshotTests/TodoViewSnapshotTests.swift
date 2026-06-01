import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class TodoViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_todoView_withData() {
        let items = [
            Todo(userId: 1, id: 1, title: "Buy groceries", body: "Milk, eggs, bread"),
            Todo(userId: 1, id: 2, title: "Finish project", body: "Complete the report"),
        ]
        let viewModel = TodoViewModel(service: SnapshotMockTodoService(data: items))
        viewModel.setItemsForSnapshot(items)

        let view = TodoView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "data", record: record)
    }

    func test_todoView_empty() {
        let viewModel = TodoViewModel(service: SnapshotMockTodoService(data: []))
        viewModel.setItemsForSnapshot([])

        let view = TodoView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "empty", record: record)
    }

    func test_todoView_withSearchActive() {
        let items = [
            Todo(userId: 1, id: 1, title: "Buy groceries", body: "Milk, eggs, bread"),
        ]
        let viewModel = TodoViewModel(service: SnapshotMockTodoService(data: items))
        viewModel.setItemsForSnapshot(items)
        viewModel.searchedText = "groceries"

        let view = TodoView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "search", record: record)
    }

    func test_todoView_loading() {
        let viewModel = TodoViewModel(service: SnapshotMockTodoService(data: []))
        viewModel.setLoadingForSnapshot(true)

        let view = TodoView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "loading", record: record)
    }

    func test_todoView_error() {
        let viewModel = TodoViewModel(service: SnapshotMockTodoService(data: []))
        viewModel.setErrorForSnapshot("Something went wrong")
        viewModel.setItemsForSnapshot([])

        let view = TodoView(viewModel: viewModel)
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

import Combine
import Foundation
import os

@MainActor
final class TodoViewModel: ObservableObject {
    @Published private(set) var items: [Todo] = []
    @Published var searchedText = ""
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let service: TodoService
    private var allItems: [Todo] = []

    var filteredItems: [Todo] {
        let query = searchedText.lowercased().trimmingCharacters(in: .whitespaces)
        if query.isEmpty {
            return allItems
        }
        return allItems.filter { $0.title.lowercased().contains(query) }
    }

    init(service: TodoService) {
        self.service = service
    }

    func fetchTodos() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let data = try await service.fetchTodos()
            allItems = data
            items = filteredItems
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch let error as NetworkError {
            AppLogger.viewModel.error("Todo fetch network error: \(error.errorDescription ?? "", privacy: .public)")
            allItems = []
            items = []
            errorMessage = error.errorDescription
        } catch {
            AppLogger.viewModel.error("Todo fetch unknown error: \(error.localizedDescription, privacy: .public)")
            allItems = []
            items = []
            errorMessage = error.localizedDescription
        }
    }

    func filterSearch() {
        items = filteredItems
    }

    // MARK: - Test Helpers
    // These methods exist for snapshot tests and previews only. Production code
    // should drive state through `fetchTodos()` and `filterSearch()`.

    func setItemsForSnapshot(_ items: [Todo]) {
        self.allItems = items
        self.items = items
    }

    func setLoadingForSnapshot(_ loading: Bool) {
        self.isLoading = loading
    }

    func setErrorForSnapshot(_ message: String?) {
        self.errorMessage = message
    }
}

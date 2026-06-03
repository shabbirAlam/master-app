import Foundation
import Observation

@MainActor
@Observable
final class TodoViewModel {
    private(set) var items: [Todo] = []
    var searchedText = ""
    private(set) var errorMessage: String?
    private(set) var isLoading = false

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
            AppLogger.viewModel.log("Todo fetch network error: \(error.errorDescription ?? "")", .error)
            allItems = []
            items = []
            errorMessage = error.errorDescription
        } catch {
            AppLogger.viewModel.log("Todo fetch unknown error: \(error.localizedDescription)", .error)
            allItems = []
            items = []
            errorMessage = error.localizedDescription
        }
    }

    func filterSearch() {
        items = filteredItems
    }

    // MARK: - Test Helpers

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

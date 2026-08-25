import Foundation
import Observation

/// Presentation state and orchestration for the todo search feature.
@MainActor
@Observable
final class TodoViewModel {
    /// Todos currently displayed (after filtering).
    private(set) var items: [Todo] = []
    /// The current search query.
    var searchedText = ""
    /// User-facing error message, or `nil` when no error occurred.
    private(set) var errorMessage: String?
    /// Whether a network request is in flight.
    private(set) var isLoading = false

    private let service: TodoService
    /// The unfiltered list of todos.
    private var allItems: [Todo] = []

    /// Applies the search query to the full list.
    var filteredItems: [Todo] {
        let query = searchedText.lowercased().trimmingCharacters(in: .whitespaces)
        if query.isEmpty {
            return allItems
        }
        return allItems.filter { $0.title.lowercased().contains(query) }
    }

    /// Creates a view model.
    /// - Parameter service: The todo service used for data access.
    init(service: TodoService) {
        self.service = service
    }

    /// Loads all todos from the service and refreshes the visible items.
    ///
    /// Cancellation is silently ignored; other failures populate `errorMessage`.
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

    /// Re-applies the current search query to the visible items.
    func filterSearch() {
        items = filteredItems
    }

    // MARK: - Test Helpers

    /// Seeds the todo list for previews and snapshot tests.
    func setItemsForSnapshot(_ items: [Todo]) {
        self.allItems = items
        self.items = items
    }

    /// Forces the loading state for previews and snapshot tests.
    func setLoadingForSnapshot(_ loading: Bool) {
        self.isLoading = loading
    }

    /// Forces the error state for previews and snapshot tests.
    func setErrorForSnapshot(_ message: String?) {
        self.errorMessage = message
    }
}

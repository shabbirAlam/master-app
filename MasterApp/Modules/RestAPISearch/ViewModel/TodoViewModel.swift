import Combine
import Foundation

@MainActor
final class TodoViewModel: ObservableObject {
    @Published var items: [Todo] = []
    @Published var searchedText = ""
    @Published var errorMsg: String?
    @Published var isLoading = false

    private let service: TodoService
    private var allItems: [Todo] = []

    init(service: TodoService) {
        self.service = service
    }

    var filteredItems: [Todo] {
        let query = searchedText.lowercased().trimmingCharacters(in: .whitespaces)
        if query.isEmpty {
            return allItems
        }
        return allItems.filter { $0.title.lowercased().contains(query) }
    }

    func fetchTodos() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let data = try await service.fetchTodos()
            allItems = data
            items = filteredItems
            errorMsg = nil
        } catch is CancellationError {
            return
        } catch {
            allItems = []
            items = []
            errorMsg = error.localizedDescription
        }
    }

    func filterSearch() {
        items = filteredItems
    }
}

//
//  TodoViewModel.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import Combine
import Foundation

@MainActor
final class TodoViewModel: ObservableObject {
    @Published var items: [Todo] = []
    @Published var searchedText = ""
    @Published var errorMsg: String? = nil
    @Published var isLoading = false
    
    let service: TodoService
    
    init(service: TodoService) {
        self.service = service
    }
    
    func fetchTodos() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let query = searchedText.lowercased()
            let data = try await service.fetchTodos()
            if query.isEmpty {
                self.items = data
            } else {
                self.items = data.filter({ $0.title.lowercased().contains(query)})
            }
            errorMsg = nil
        } catch is CancellationError {
            return
        } catch {
            self.items = []
            errorMsg = error.localizedDescription
        }
    }
}

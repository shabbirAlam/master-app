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
            items = try await service.fetchTodos()
            errorMsg = nil
        } catch {
            errorMsg = error.localizedDescription
        }
    }
}

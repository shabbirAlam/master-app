//
//  TodoViewModel.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import Combine
import Foundation

final class TodoViewModel: ObservableObject {
    @Published var items: [Todo] = []
    @Published var errorMsg: String? = nil
    @Published var isLoading = false
    
    let service: TodoService
    
    init(service: TodoService) {
        self.service = service
    }
    
    func fetchTodo() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await service.fetchTodos()
            errorMsg = nil
        } catch let error as AppError {
            errorMsg = error.localizedDescription
        } catch {
            errorMsg = "Something went wrong"
        }
    }
}

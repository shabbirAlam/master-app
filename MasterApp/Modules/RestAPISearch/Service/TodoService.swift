//
//  TodoService.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import Foundation

protocol TodoService {
    func fetchTodos() async throws -> [Todo]
}

final class TodoServiceImpl: TodoService {
    private let networking: Networking
    
    init(networking: Networking) {
        self.networking = networking
    }
    
    func fetchTodos() async throws -> [Todo] {
        try await Task.sleep(nanoseconds: 500_000_000)
        try Task.checkCancellation()
        guard let url = URL(string: "\(ApiConfig.todoBaseURL)posts") else {
            throw NetworkError.unknown
        }
        return try await networking.request(url)
    }
}

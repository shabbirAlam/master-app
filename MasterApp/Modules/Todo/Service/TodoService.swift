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
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { throw AppError.unknown }
        do {
            return try await networking.request(url)
        } catch let error as NetworkError  {
            throw ErrorMapper.map(error)
        }
    }
}

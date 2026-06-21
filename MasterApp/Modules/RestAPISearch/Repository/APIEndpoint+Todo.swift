import Foundation

extension APIEndpoint {
    static var todos: Self {
        .init(baseURL: ApiConfig.todoBaseURL,
              path: "posts")
    }
}

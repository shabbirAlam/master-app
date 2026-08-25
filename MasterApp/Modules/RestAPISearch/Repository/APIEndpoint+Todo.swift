import Foundation

extension APIEndpoint {
    /// Endpoint for the JSONPlaceholder "posts" resource used by the todo feature.
    static var todos: Self {
        .init(baseURL: ApiConfig.todoBaseURL,
              path: "posts")
    }
}

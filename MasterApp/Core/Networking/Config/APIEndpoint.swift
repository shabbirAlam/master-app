import Foundation

/// Concrete, value-based implementation of `Endpoint` with sensible defaults.
///
/// Used by feature repositories to describe REST requests without defining
/// dedicated enum types.
struct APIEndpoint: Endpoint {
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let queryItems: [URLQueryItem]?
    let body: Encodable?
    var timeout: TimeInterval

    /// Creates an endpoint configuration.
    /// - Parameters:
    ///   - baseURL: The API base URL (defaults to `ApiConfig.baseURL`).
    ///   - path: The request path.
    ///   - method: The HTTP method (defaults to `.GET`).
    ///   - headers: Optional request headers.
    ///   - queryItems: Optional URL query items.
    ///   - body: Optional encodable request body.
    ///   - timeout: Request timeout in seconds (defaults to 30).
    init(baseURL: String = ApiConfig.baseURL,
         path: String,
         method: HTTPMethod = .GET,
         headers: [String: String]? = nil,
         queryItems: [URLQueryItem]? = nil,
         body: Encodable? = nil,
         timeout: TimeInterval = 30) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
        self.timeout = timeout
    }
}

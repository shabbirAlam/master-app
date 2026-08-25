import Foundation

/// Describes a REST API endpoint: its location, method, and payload.
///
/// Conforming types (typically enums) provide all information needed to build
/// a `URLRequest` via `Endpoint+Request`.
protocol Endpoint: Sendable {
    /// The API base URL, e.g. `"https://api.example.com"`.
    var baseURL: String { get }
    /// The path appended to the base URL.
    var path: String { get }
    /// The HTTP method for the request.
    var method: HTTPMethod { get }
    /// Optional request headers.
    var headers: [String: String]? { get }
    /// Optional URL query items.
    var queryItems: [URLQueryItem]? { get }
    /// Optional encodable request body.
    var body: Encodable? { get }
    /// Request timeout interval in seconds.
    var timeout: TimeInterval { get }
}

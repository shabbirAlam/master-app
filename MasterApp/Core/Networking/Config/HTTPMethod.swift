import Foundation

/// Supported HTTP methods for REST requests.
enum HTTPMethod: String, Sendable {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

import Foundation

/// The standard GraphQL JSON envelope, exposing the decoded `data` payload.
struct GraphQLResponse<T: Decodable>: Decodable {
    /// The query result data returned by the server.
    let data: T
}

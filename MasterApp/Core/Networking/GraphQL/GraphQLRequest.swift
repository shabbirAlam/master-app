import Foundation

/// JSON body of a GraphQL HTTP request containing the query and optional variables.
///
/// Custom encoding omits the `variables` key entirely when no variables are set.
struct GraphQLRequest: Encodable {
    /// The GraphQL query string.
    let query: String
    /// Optional variables passed to the query.
    let variables: [String: AnyEncodable]?

    enum CodingKeys: String, CodingKey {
        case query
        case variables
    }

    /// Encodes the request, omitting `variables` when absent.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        if let variables {
            try container.encode(AnyEncodable(variables), forKey: .variables)
        }
    }
}

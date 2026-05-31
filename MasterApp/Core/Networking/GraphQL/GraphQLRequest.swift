import Foundation

struct GraphQLRequest: Encodable {
    let query: String
    let variables: [String: AnyEncodable]?

    enum CodingKeys: String, CodingKey {
        case query
        case variables
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        if let variables {
            try container.encode(AnyEncodable(variables), forKey: .variables)
        }
    }
}

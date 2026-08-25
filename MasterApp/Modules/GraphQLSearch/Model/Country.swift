import Foundation

/// A country returned by the GraphQL countries API.
struct Country: Codable, Hashable, Identifiable {
    /// ISO country code, e.g. `"US"`.
    let code: String
    /// The country's display name.
    let name: String
    /// The capital city, if any.
    let capital: String?

    /// Stable identity derived from the country code.
    var id: String { code }
}

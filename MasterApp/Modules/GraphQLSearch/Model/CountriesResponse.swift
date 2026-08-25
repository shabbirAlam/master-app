import Foundation

/// Decodable payload for the countries list GraphQL query.
struct CountriesResponse: Decodable {
    /// The countries matching the query.
    let countries: [Country]
}

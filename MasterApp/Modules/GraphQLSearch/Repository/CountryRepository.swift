import Foundation

/// Data access contract for country lookups via GraphQL.
protocol CountryRepository: Sendable {
    /// Fetches all countries.
    /// - Returns: The full list of countries.
    /// - Throws: `NetworkError` on request or decoding failure.
    func fetchCountries() async throws -> [Country]
    /// Fetches a single country by code.
    /// - Parameter code: The ISO country code.
    /// - Returns: The matching country.
    /// - Throws: `NetworkError` on request or decoding failure.
    func fetchCountry(for code: String) async throws -> Country
}

/// Default `CountryRepository` backed by `GraphQLNetworking`.
final class CountryRepositoryImpl: CountryRepository {
    private let networking: GraphQLNetworking

    /// Creates a repository.
    /// - Parameter networking: The GraphQL client used for data access.
    init(networking: GraphQLNetworking) {
        self.networking = networking
        AppLogger.repository.log("CountryRepositoryImpl initialized", .info)
    }

    /// Fetches all countries using a list query.
    func fetchCountries() async throws -> [Country] {
        AppLogger.repository.log("Fetching all countries", .info)
        let query = """
            query {
                countries {
                    code
                    name
                    capital
                }
            }
            """
        let response: CountriesResponse = try await networking.fetch(query: query, variables: nil)
        return response.countries
    }

    /// Fetches a single country by ISO code using a parameterized query.
    /// - Parameter code: The ISO country code.
    /// - Returns: The matching country.
    /// - Throws: `NetworkError` on request or decoding failure.
    func fetchCountry(for code: String) async throws -> Country {
        AppLogger.repository.log("Fetching country for code: \(code)", .info)
        let query = """
        query GetCountry($code: ID!) {
          country(code: $code) {
            name
            capital
            code
          }
        }
        """

        let variables = [
            "code": AnyEncodable(code)
        ]

        let result: CountryWrapper = try await networking.fetch(query: query, variables: variables)
        return result.country
    }
}

import Foundation

protocol CountryRepository: Sendable {
    func fetchCountries() async throws -> [Country]
    func fetchCountry(for code: String) async throws -> Country
}

final class CountryRepositoryImpl: CountryRepository {
    private let networking: GraphQLNetworking

    init(networking: GraphQLNetworking) {
        self.networking = networking
        AppLogger.repository.log("CountryRepositoryImpl initialized", .info)
    }

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

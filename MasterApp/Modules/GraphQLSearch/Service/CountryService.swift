import Foundation

/// Business-logic contract for country workflows.
protocol CountryService: Sendable {
    /// Fetches all countries.
    /// - Returns: The full list of countries.
    /// - Throws: Any error propagated by the repository.
    func fetchCountries() async throws -> [Country]
    /// Fetches a single country by code.
    /// - Parameter code: The ISO country code.
    /// - Returns: The matching country.
    /// - Throws: Any error propagated by the repository.
    func fetchCountry(for code: String) async throws -> Country
}

/// Default `CountryService` delegating to a `CountryRepository`.
final class CountryServiceImpl: CountryService {
    private let repository: CountryRepository

    /// Creates a service.
    /// - Parameter repository: The country data source.
    init(repository: CountryRepository) {
        self.repository = repository
        AppLogger.service.log("CountryServiceImpl initialized", .info)
    }

    /// Fetches all countries via the repository.
    func fetchCountries() async throws -> [Country] {
        AppLogger.service.log("Fetching all countries", .info)
        return try await repository.fetchCountries()
    }

    /// Fetches a single country by ISO code via the repository.
    /// - Parameter code: The ISO country code.
    /// - Returns: The matching country.
    /// - Throws: Any error propagated by the repository.
    func fetchCountry(for code: String) async throws -> Country {
        AppLogger.service.log("Fetching country for code: \(code)", .info)
        return try await repository.fetchCountry(for: code)
    }
}

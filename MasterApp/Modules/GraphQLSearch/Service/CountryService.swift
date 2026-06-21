import Foundation

protocol CountryService: Sendable {
    func fetchCountries() async throws -> [Country]
    func fetchCountry(for code: String) async throws -> Country
}

final class CountryServiceImpl: CountryService {
    private let repository: CountryRepository

    init(repository: CountryRepository) {
        self.repository = repository
        AppLogger.service.log("CountryServiceImpl initialized", .info)
    }

    func fetchCountries() async throws -> [Country] {
        AppLogger.service.log("Fetching all countries", .info)
        return try await repository.fetchCountries()
    }

    func fetchCountry(for code: String) async throws -> Country {
        AppLogger.service.log("Fetching country for code: \(code)", .info)
        return try await repository.fetchCountry(for: code)
    }
}

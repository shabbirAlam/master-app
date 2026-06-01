import Foundation

protocol CountryService: Sendable {
    func fetchCountries() async throws -> [Country]
    func fetchCountry(for code: String) async throws -> Country
}

final class CountryServiceImpl: CountryService {
    private let repository: CountryRepository

    init(repository: CountryRepository) {
        self.repository = repository
    }

    func fetchCountries() async throws -> [Country] {
        try await repository.fetchCountries()
    }

    func fetchCountry(for code: String) async throws -> Country {
        try await repository.fetchCountry(for: code)
    }
}

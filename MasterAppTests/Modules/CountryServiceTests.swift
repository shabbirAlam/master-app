import Foundation
import Testing
@testable import MasterApp

@MainActor
final class MockCountryRepository: CountryRepository {
    private var mockData: Data?
    private var mockError: Error?

    func fetchCountries() async throws -> [Country] {
        if let mockError { throw mockError }
        if let data = mockData {
            return try JSONDecoder().decode(CountriesResponse.self, from: data).countries
        }
        return []
    }

    func fetchCountry(for code: String) async throws -> Country {
        if let mockError { throw mockError }
        if let data = mockData {
            return try JSONDecoder().decode(CountryWrapper.self, from: data).country
        }
        throw NetworkError.unknown
    }

    func setMockData(_ data: Data) { mockData = data }
    func setError(_ error: Error) { mockError = error }
}

@MainActor
struct CountryServiceTests {
    @Test func fetchCountriesSuccess() async throws {
        let mock = MockCountryRepository()
        let jsonData = """
        {"countries": [{"code": "IN", "name": "India", "capital": "Delhi"}]}
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let service = CountryServiceImpl(repository: mock)
        let countries = try await service.fetchCountries()

        #expect(countries.count == 1)
        #expect(countries[0].name == "India")
        #expect(countries[0].code == "IN")
    }

    @Test func fetchCountrySuccess() async throws {
        let mock = MockCountryRepository()
        let jsonData = """
        {"country": {"code": "IN", "name": "India", "capital": "Delhi"}}
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let service = CountryServiceImpl(repository: mock)
        let country = try await service.fetchCountry(for: "IN")

        #expect(country.name == "India")
        #expect(country.code == "IN")
        #expect(country.capital == "Delhi")
    }

    @Test func fetchCountriesError() async {
        let mock = MockCountryRepository()
        mock.setError(URLError(.notConnectedToInternet))

        let service = CountryServiceImpl(repository: mock)

        do {
            let _ = try await service.fetchCountries()
            Issue.record("Expected error")
        } catch {
            #expect(error is URLError)
        }
    }

}

import Foundation
import Testing
@testable import MasterApp

@MainActor
struct CountryServiceTests {
    @Test func fetchCountriesSuccess() async throws {
        let mock = MockGraphQLNetworking()
        let jsonData = """
        {"countries": [{"code": "IN", "name": "India", "capital": "Delhi"}]}
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let service = CountryServiceImpl(networking: mock)
        let countries = try await service.fetchCountries()

        #expect(countries.count == 1)
        #expect(countries[0].name == "India")
        #expect(countries[0].code == "IN")
    }

    @Test func fetchCountrySuccess() async throws {
        let mock = MockGraphQLNetworking()
        let jsonData = """
        {"country": {"code": "IN", "name": "India", "capital": "Delhi"}}
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let service = CountryServiceImpl(networking: mock)
        let country = try await service.fetchCountry(for: "IN")

        #expect(country.name == "India")
        #expect(country.code == "IN")
        #expect(country.capital == "Delhi")
    }

    @Test func fetchCountriesError() async {
        let mock = MockGraphQLNetworking()
        mock.setError(URLError(.notConnectedToInternet))

        let service = CountryServiceImpl(networking: mock)

        do {
            let _ = try await service.fetchCountries()
            Issue.record("Expected error")
        } catch {
            #expect(error is URLError)
        }
    }

    @Test func fetchCountryError() async {
        let mock = MockGraphQLNetworking()
        mock.setError(NetworkError.unknown)

        let service = CountryServiceImpl(networking: mock)

        do {
            let _ = try await service.fetchCountry(for: "IN")
            Issue.record("Expected error")
        } catch {
            #expect(true)
        }
    }
}

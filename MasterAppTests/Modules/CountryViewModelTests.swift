import Foundation
import Testing
@testable import MasterApp

@MainActor
final class MockGraphQLNetworking: GraphQLNetworking {
    private var mockData: Data?
    private var mockError: Error?
    
    func fetch<T: Decodable>(query: String, variables: [String: AnyEncodable]?) async throws -> T {
        if let mockError { throw mockError }
        if let data = mockData { return try JSONDecoder().decode(T.self, from: data) }
        throw URLError(.unknown)
    }
    
    func setMockData(_ data: Data) { mockData = data }
    func setError(_ error: Error) { mockError = error }
}

@MainActor
struct CountryViewModelTests {
    
    @Test
    func fetchCountriesSuccess() async {
        let mock = MockGraphQLNetworking()
        let jsonData = """
        {
            "countries": [
                {"code": "IN", "name": "India", "capital": "Delhi"},
                {"code": "US", "name": "United States", "capital": "Washington"}
            ]
        }
        """.data(using: .utf8)!
        mock.setMockData(jsonData)
        
        let vm = CountryViewModel(networking: mock)
        
        await vm.fetchCountries()
        
        #expect(vm.isLoading == false)
        #expect(vm.countries.count == 2)
        #expect(vm.countries[0].name == "India")
        #expect(vm.countries[1].name == "United States")
        #expect(vm.errorMessage == nil)
    }
    
    @Test
    func fetchCountriesFailure() async {
        let mock = MockGraphQLNetworking()
        mock.setError(URLError(.notConnectedToInternet))
        
        let vm = CountryViewModel(networking: mock)
        
        await vm.fetchCountries()
        
        #expect(vm.isLoading == false)
        #expect(vm.countries.isEmpty)
        #expect(vm.errorMessage != nil)
    }
    
    @Test
    func filterCountries() async {
        let mock = MockGraphQLNetworking()
        let jsonData = """
        {
            "countries": [
                {"code": "IN", "name": "India", "capital": "Delhi"},
                {"code": "US", "name": "United States", "capital": "Washington"},
                {"code": "ID", "name": "Indonesia", "capital": "Jakarta"}
            ]
        }
        """.data(using: .utf8)!
        mock.setMockData(jsonData)
        
        let vm = CountryViewModel(networking: mock)
        await vm.fetchCountries()
        
        vm.searchedText = "ind"
        vm.filterCountries()
        
        #expect(vm.countries.count == 2)
        #expect(vm.countries[0].name == "India")
        #expect(vm.countries[1].name == "Indonesia")
    }
    
    @Test
    func filterCountriesEmptySearch() async {
        let mock = MockGraphQLNetworking()
        let jsonData = """
        {
            "countries": [
                {"code": "IN", "name": "India", "capital": "Delhi"},
                {"code": "US", "name": "United States", "capital": "Washington"}
            ]
        }
        """.data(using: .utf8)!
        mock.setMockData(jsonData)
        
        let vm = CountryViewModel(networking: mock)
        await vm.fetchCountries()
        
        vm.searchedText = ""
        vm.filterCountries()
        
        #expect(vm.countries.count == 2)
    }
    
    @Test
    func fetchCountrySuccess() async {
        let mock = MockGraphQLNetworking()
        let jsonData = """
        {"country": {"code": "IN", "name": "India", "capital": "Delhi"}}
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let vm = CountryViewModel(networking: mock)
        await vm.fetchCountry(Country(code: "IN", name: "India", capital: "Delhi"))

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test
    func filterCountriesNoMatch() async {
        let mock = MockGraphQLNetworking()
        let jsonData = """
        {
            "countries": [
                {"code": "IN", "name": "India", "capital": "Delhi"}
            ]
        }
        """.data(using: .utf8)!
        mock.setMockData(jsonData)
        
        let vm = CountryViewModel(networking: mock)
        await vm.fetchCountries()
        
        vm.searchedText = "zzzzz"
        vm.filterCountries()
        
        #expect(vm.countries.isEmpty)
    }

    @Test
    func fetchCountryError() async {
        let mock = MockGraphQLNetworking()
        mock.setError(URLError(.notConnectedToInternet))

        let vm = CountryViewModel(networking: mock)
        let country = Country(code: "XX", name: "Unknown", capital: nil)
        await vm.fetchCountry(country)

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
    }

    @Test
    func fetchCountriesEmptyData() async {
        let mock = MockGraphQLNetworking()
        let jsonData = """
        {"countries": []}
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let vm = CountryViewModel(networking: mock)
        await vm.fetchCountries()

        #expect(vm.isLoading == false)
        #expect(vm.countries.isEmpty)
        #expect(vm.countriesData.isEmpty)
        #expect(vm.errorMessage == nil)
    }
}

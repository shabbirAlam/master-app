import Foundation
import Testing
@testable import MasterApp

@MainActor
struct CountryViewModelTests {

    @Test
    func fetchCountriesSuccess() async {
        let mock = MockCountryRepository()
        let jsonData = """
        {
            "countries": [
                {"code": "IN", "name": "India", "capital": "Delhi"},
                {"code": "US", "name": "United States", "capital": "Washington"}
            ]
        }
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))

        await vm.fetchCountries()

        #expect(vm.isLoading == false)
        #expect(vm.filteredCountries.count == 2)
        #expect(vm.filteredCountries[0].name == "India")
        #expect(vm.filteredCountries[1].name == "United States")
        #expect(vm.errorMessage == nil)
    }

    @Test
    func fetchCountriesFailure() async {
        let mock = MockCountryRepository()
        mock.setError(URLError(.notConnectedToInternet))

        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))

        await vm.fetchCountries()

        #expect(vm.isLoading == false)
        #expect(vm.filteredCountries.isEmpty)
        #expect(vm.errorMessage != nil)
    }

    @Test
    func filterCountries() async {
        let mock = MockCountryRepository()
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

        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))
        await vm.fetchCountries()

        vm.searchedText = "ind"
        vm.filterCountries()

        #expect(vm.filteredCountries.count == 2)
        #expect(vm.filteredCountries[0].name == "India")
        #expect(vm.filteredCountries[1].name == "Indonesia")
    }

    @Test
    func filterCountriesEmptySearch() async {
        let mock = MockCountryRepository()
        let jsonData = """
        {
            "countries": [
                {"code": "IN", "name": "India", "capital": "Delhi"},
                {"code": "US", "name": "United States", "capital": "Washington"}
            ]
        }
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))
        await vm.fetchCountries()

        vm.searchedText = ""
        vm.filterCountries()

        #expect(vm.filteredCountries.count == 2)
    }

    @Test
    func fetchCountrySuccess() async {
        let mock = MockCountryRepository()
        let jsonData = """
        {"country": {"code": "IN", "name": "India", "capital": "Delhi"}}
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))
        await vm.fetchCountry(Country(code: "IN", name: "India", capital: "Delhi"))

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test
    func filterCountriesNoMatch() async {
        let mock = MockCountryRepository()
        let jsonData = """
        {
            "countries": [
                {"code": "IN", "name": "India", "capital": "Delhi"}
            ]
        }
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))
        await vm.fetchCountries()

        vm.searchedText = "zzzzz"
        vm.filterCountries()

        #expect(vm.filteredCountries.isEmpty)
    }

    @Test
    func fetchCountryError() async {
        let mock = MockCountryRepository()
        mock.setError(URLError(.notConnectedToInternet))

        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))
        let country = Country(code: "XX", name: "Unknown", capital: nil)
        await vm.fetchCountry(country)

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
    }

    @Test
    func fetchCountriesEmptyData() async {
        let mock = MockCountryRepository()
        let jsonData = """
        {"countries": []}
        """.data(using: .utf8)!
        mock.setMockData(jsonData)

        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))
        await vm.fetchCountries()

        #expect(vm.isLoading == false)
        #expect(vm.filteredCountries.isEmpty)
        #expect(vm.errorMessage == nil)
    }

    @Test
    func setLoadingForSnapshot() async {
        let mock = MockCountryRepository()
        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))
        #expect(vm.isLoading == false)

        vm.setLoadingForSnapshot(true)
        #expect(vm.isLoading == true)

        vm.setLoadingForSnapshot(false)
        #expect(vm.isLoading == false)
    }

    @Test
    func fetchCountriesCancellation() async {
        let mock = MockCountryRepository()
        mock.setError(CancellationError())
        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))

        await vm.fetchCountries()

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test
    func fetchCountriesGenericError() async {
        let mock = MockCountryRepository()
        struct SomeError: Error {}
        mock.setError(SomeError())
        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))

        await vm.fetchCountries()

        #expect(vm.isLoading == false)
        #expect(vm.filteredCountries.isEmpty)
        #expect(vm.errorMessage != nil)
    }

    @Test
    func fetchCountryCancellation() async {
        let mock = MockCountryRepository()
        mock.setError(CancellationError())
        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))

        await vm.fetchCountry(Country(code: "XX", name: "Test", capital: nil))

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test
    func fetchCountryGenericError() async {
        let mock = MockCountryRepository()
        struct SomeError: Error {}
        mock.setError(SomeError())
        let vm = CountryViewModel(service: CountryServiceImpl(repository: mock))

        await vm.fetchCountry(Country(code: "XX", name: "Test", capital: nil))

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
    }
}

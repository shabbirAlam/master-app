import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class CountryViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_countryView_withData() {
        let vm = CountryViewModel(service: SnapshotMockCountryService(data: [
            Country(code: "IN", name: "India", capital: "New Delhi"),
            Country(code: "US", name: "United States", capital: "Washington DC"),
            Country(code: "JP", name: "Japan", capital: "Tokyo"),
        ]))
        vm.allCountries = [
            Country(code: "IN", name: "India", capital: "New Delhi"),
            Country(code: "US", name: "United States", capital: "Washington DC"),
            Country(code: "JP", name: "Japan", capital: "Tokyo"),
        ]
        vm.filterCountries()

        let view = CountryView(vm: vm)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "data", record: record)
    }

    func test_countryView_withSearch() {
        let vm = CountryViewModel(service: SnapshotMockCountryService(data: [
            Country(code: "IN", name: "India", capital: "New Delhi"),
            Country(code: "US", name: "United States", capital: "Washington DC"),
            Country(code: "JP", name: "Japan", capital: "Tokyo"),
        ]))
        vm.allCountries = [
            Country(code: "IN", name: "India", capital: "New Delhi"),
            Country(code: "US", name: "United States", capital: "Washington DC"),
            Country(code: "JP", name: "Japan", capital: "Tokyo"),
        ]
        vm.searchedText = "in"
        vm.filterCountries()

        let view = CountryView(vm: vm)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "search", record: record)
    }

    func test_countryView_empty() {
        let vm = CountryViewModel(service: SnapshotMockCountryService(data: []))
        vm.allCountries = []
        vm.filterCountries()

        let view = CountryView(vm: vm)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "empty", record: record)
    }

    func test_countryView_error() {
        let vm = CountryViewModel(service: SnapshotMockCountryService(data: []))
        vm.errorMessage = "Network error occurred"

        let view = CountryView(vm: vm)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "error", record: record)
    }
}

private final class SnapshotMockCountryService: CountryService {
    let data: [Country]
    init(data: [Country]) { self.data = data }
    func fetchCountries() async throws -> [Country] { data }
    func fetchCountry(for code: String) async throws -> Country {
        Country(code: code, name: code, capital: nil)
    }
}

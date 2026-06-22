import XCTest
import SnapshotTesting
import SwiftUI
@testable import MasterApp

@MainActor
final class CountryViewSnapshotTests: XCTestCase {
    let record: SnapshotTestingConfiguration.Record = .never

    func test_countryView_withData() {
        let countries = [
            Country(code: "IN", name: "India", capital: "New Delhi"),
            Country(code: "US", name: "United States", capital: "Washington DC"),
            Country(code: "JP", name: "Japan", capital: "Tokyo"),
        ]
        let viewModel = CountryViewModel(service: SnapshotMockCountryService(data: countries))
        viewModel.setCountriesForSnapshot(countries)

        let view = CountryView(viewModel: viewModel, theme: AppTheme.light)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "data", record: record)
    }

    func test_countryView_withSearch() {
        let countries = [
            Country(code: "IN", name: "India", capital: "New Delhi"),
            Country(code: "US", name: "United States", capital: "Washington DC"),
            Country(code: "JP", name: "Japan", capital: "Tokyo"),
        ]
        let viewModel = CountryViewModel(service: SnapshotMockCountryService(data: countries))
        viewModel.setCountriesForSnapshot(countries)
        viewModel.searchedText = "in"
        viewModel.filterCountries()

        let view = CountryView(viewModel: viewModel, theme: AppTheme.light)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "search", record: record)
    }

    func test_countryView_empty() {
        let viewModel = CountryViewModel(service: SnapshotMockCountryService(data: []))
        viewModel.setCountriesForSnapshot([])

        let view = CountryView(viewModel: viewModel, theme: AppTheme.light)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "empty", record: record)
    }

    func test_countryView_error() {
        let viewModel = CountryViewModel(service: SnapshotMockCountryService(data: []))
        viewModel.setErrorForSnapshot("Network error occurred")

        let view = CountryView(viewModel: viewModel, theme: AppTheme.light)
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

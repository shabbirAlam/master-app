import Combine
import Foundation
import os

@MainActor
final class CountryViewModel: ObservableObject {
    @Published private(set) var filteredCountries: [Country] = []
    @Published var searchedText = ""
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let service: CountryService
    private var allCountries: [Country] = []

    init(service: CountryService) {
        self.service = service
    }

    func fetchCountries() async {
        isLoading = true
        defer { isLoading = false }
        do {
            allCountries = try await service.fetchCountries()
            filterCountries()
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch let error as NetworkError {
            AppLogger.viewModel.error("Country fetch network error: \(error.errorDescription ?? "", privacy: .public)")
            allCountries = []
            errorMessage = error.errorDescription
        } catch {
            AppLogger.viewModel.error("Country fetch unknown error: \(error.localizedDescription, privacy: .public)")
            allCountries = []
            errorMessage = error.localizedDescription
        }
    }

    func fetchCountry(_ country: Country) async {
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await service.fetchCountry(for: country.code)
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func filterCountries() {
        if searchedText.isEmpty {
            filteredCountries = allCountries
        } else {
            filteredCountries = allCountries.filter {
                $0.name.localizedCaseInsensitiveContains(searchedText)
            }
        }
    }

    // MARK: - Test Helpers

    func setCountriesForSnapshot(_ countries: [Country]) {
        self.allCountries = countries
        self.filteredCountries = countries
    }

    func setLoadingForSnapshot(_ loading: Bool) {
        self.isLoading = loading
    }

    func setErrorForSnapshot(_ message: String?) {
        self.errorMessage = message
    }
}

import Foundation
import Observation

@MainActor
@Observable
final class CountryViewModel {
    private(set) var filteredCountries: [Country] = []
    var searchedText = ""
    private(set) var errorMessage: String?
    private(set) var isLoading = false

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
            AppLogger.viewModel.log("Country fetch network error: \(error.errorDescription ?? "")", .error)
            allCountries = []
            errorMessage = error.errorDescription
        } catch {
            AppLogger.viewModel.log("Country fetch unknown error: \(error.localizedDescription)", .error)
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
            AppLogger.viewModel.log("Country detail fetch error: \(error.errorDescription ?? "")", .error)
            errorMessage = error.errorDescription
        } catch {
            AppLogger.viewModel.log("Country detail fetch unknown error: \(error.localizedDescription)", .error)
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

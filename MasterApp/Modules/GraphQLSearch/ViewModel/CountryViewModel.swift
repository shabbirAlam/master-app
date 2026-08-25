import Foundation
import Observation

/// Presentation state and orchestration for the country search feature.
///
/// Holds the full country list, applies text filtering, and surfaces
/// loading/error state for the view.
@MainActor
@Observable
final class CountryViewModel {
    /// Countries matching the current search text.
    private(set) var filteredCountries: [Country] = []
    /// The current search query.
    var searchedText = ""
    /// User-facing error message, or `nil` when no error occurred.
    private(set) var errorMessage: String?
    /// Whether a network request is in flight.
    private(set) var isLoading = false

    private let service: CountryService
    /// The unfiltered list of countries.
    private var allCountries: [Country] = []

    /// Creates a view model.
    /// - Parameter service: The country service used for data access.
    init(service: CountryService) {
        self.service = service
    }

    /// Loads all countries from the service and refreshes the filtered list.
    ///
    /// Cancellation is silently ignored; other failures populate `errorMessage`.
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

    /// Re-fetches details for a tapped country.
    ///
    /// Failures populate `errorMessage`; cancellation is ignored.
    /// - Parameter country: The country whose details to fetch.
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

    /// Recomputes `filteredCountries` from the full list using `searchedText`.
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

    /// Seeds the country list for previews and snapshot tests.
    func setCountriesForSnapshot(_ countries: [Country]) {
        self.allCountries = countries
        self.filteredCountries = countries
    }

    /// Forces the loading state for previews and snapshot tests.
    func setLoadingForSnapshot(_ loading: Bool) {
        self.isLoading = loading
    }

    /// Forces the error state for previews and snapshot tests.
    func setErrorForSnapshot(_ message: String?) {
        self.errorMessage = message
    }
}

import Combine
import Foundation

@MainActor
final class CountryViewModel: ObservableObject {
    var allCountries: [Country] = []
    @Published var filteredCountries: [Country] = []
    @Published var searchedText = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let service: CountryService

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
        } catch {
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
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func filterCountries() {
        if searchedText.isEmpty {
            filteredCountries = allCountries
        } else {
            filteredCountries = allCountries.filter { $0.name.localizedCaseInsensitiveContains(searchedText) }
        }
    }
}

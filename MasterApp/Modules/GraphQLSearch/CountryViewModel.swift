//
//  CountryViewModel.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 19/04/26.
//

import Combine
import Foundation

@MainActor
final class CountryViewModel: ObservableObject {
    var countriesData: [Country] = []
    @Published var countries: [Country] = []
    @Published var searchedText = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    let service: CountryService
    
    init(networking: GraphQLNetworking) {
        service = CountryService(networking: networking)
    }
    
    func fetchCountries() async {
        isLoading = true
        defer { isLoading = false }
        do {
            countriesData = try await service.fetchCountries()
            filterCountries()
            errorMessage = nil
        } catch {
            self.countriesData = []
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchCountry(_ country: Country) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let country = try await service.fetchCountry(for: country.code)
            print(country)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func filterCountries() {
        if searchedText.isEmpty {
            countries = countriesData
        } else {
            countries = countriesData.filter { $0.name.localizedCaseInsensitiveContains(searchedText) }
        }
    }
}

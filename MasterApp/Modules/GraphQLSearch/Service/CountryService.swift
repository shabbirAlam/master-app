//
//  CountryService.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 19/04/26.
//

import Foundation

final class CountryService {
    private let networking: GraphQLNetworking
    
    init(networking: GraphQLNetworking) {
        self.networking = networking
    }
    
    func fetchCountries() async throws -> [Country] {
        let query = """
            query {
                countries {
                    code
                    name
                    capital
                }
            }
            """
        let response: CountriesResponse = try await networking.fetch(query: query, variables: nil)
        return response.countries
    }
    
    func fetchCountry(for code: String) async throws -> Country {
        let query = """
        query GetCountry($code: ID!) {
          country(code: $code) {
            name
            capital
            code
          }
        }
        """
        
        let variables = [
            "code": AnyEncodable(code)
        ]
        
        let result: CountryWrapper = try await networking.fetch(query: query, variables: variables)
        return result.country
    }
}

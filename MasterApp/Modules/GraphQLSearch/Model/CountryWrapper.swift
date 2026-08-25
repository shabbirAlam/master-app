//
//  CountryWrapper.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 19/04/26.
//

import Foundation

/// Decodable payload for the single-country GraphQL query.
struct CountryWrapper: Decodable {
    /// The country matching the queried code.
    let country: Country
}

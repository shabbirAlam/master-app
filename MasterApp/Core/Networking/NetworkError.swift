//
//  NetworkError.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 23/04/26.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case badStatusCode(Int)
}

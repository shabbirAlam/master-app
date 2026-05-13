//
//  GraphQLRequest.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 19/04/26.
//

import Foundation

struct GraphQLRequest: Encodable {
    let query: String
    let variables: [String: AnyEncodable]?
}

struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    
    init<T: Encodable>(_ value: T) {
        encodeFunc = value.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

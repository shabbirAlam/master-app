//
//  GraphQLResponse.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 19/04/26.
//

import Foundation

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T
}

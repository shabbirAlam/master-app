//
//  Todo.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Foundation

struct Todo: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

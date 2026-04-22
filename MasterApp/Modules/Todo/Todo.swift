//
//  Todo.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Foundation

struct Todo: Codable {
    let id: Int
    let title: String
    let completed: Bool
    let userId: Int
}

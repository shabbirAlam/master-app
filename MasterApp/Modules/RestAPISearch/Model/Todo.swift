//
//  Todo.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 22/04/26.
//

import Foundation

/// A todo item returned by the JSONPlaceholder API.
struct Todo: Codable {
    /// The owning user's identifier.
    let userId: Int
    /// The todo's unique identifier.
    let id: Int
    /// The todo title.
    let title: String
    /// The todo body text.
    let body: String
}

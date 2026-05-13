//
//  Theme.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 13/05/26.
//

import SwiftUI

protocol Theme {
    var background: Color { get }
    var textPrimary: Color { get }
}

struct ThemeManager: Theme {
    static let shared: Theme = ThemeManager()
    private init() {}
    
    let background: Color = .white
    let textPrimary: Color = .black
}

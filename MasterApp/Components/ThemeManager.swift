//
//  ThemeManager.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Combine
import SwiftUI

final class ThemeManager: ObservableObject {
    @Published var current: Theme = .light
    
    func update(for scheme: ColorScheme) {
        current = (scheme == .dark) ? .dark : .light
    }
}

extension Theme {
    static let light = Theme(
        background: Color.white,
        surface: Color(.systemGray6),
        elevatedSurface: Color.white,
        
        textPrimary: Color.black,
        textSecondary: Color.gray,
        textInverse: Color.white,
        
        primary: Color.blue,
        primaryVariant: Color.blue.opacity(0.8),
        secondary: Color.purple,
        
        buttonPrimaryBackground: Color.blue,
        buttonPrimaryText: Color.white,
        
        buttonSecondaryBackground: Color.gray.opacity(0.15),
        buttonSecondaryText: Color.black,
        
        buttonDisabledBackground: Color.gray.opacity(0.2),
        buttonDisabledText: Color.gray,
        
        success: Color.green,
        warning: Color.orange,
        error: Color.red,
        info: Color.cyan,
        
        border: Color.gray.opacity(0.3),
        divider: Color.gray.opacity(0.2),
        
        overlay: Color.black.opacity(0.4)
    )
}

extension Theme {
    static let dark = Theme(
        background: Color.black,
        surface: Color(.systemGray5),
        elevatedSurface: Color(.systemGray6),
        
        textPrimary: Color.white,
        textSecondary: Color.gray,
        textInverse: Color.black,
        
        primary: Color.blue,
        primaryVariant: Color.blue.opacity(0.7),
        secondary: Color.purple,
        
        buttonPrimaryBackground: Color.blue,
        buttonPrimaryText: Color.white,
        
        buttonSecondaryBackground: Color.white.opacity(0.1),
        buttonSecondaryText: Color.white,
        
        buttonDisabledBackground: Color.gray.opacity(0.3),
        buttonDisabledText: Color.gray,
        
        success: Color.green,
        warning: Color.orange,
        error: Color.red,
        info: Color.cyan,
        
        border: Color.gray.opacity(0.4),
        divider: Color.gray.opacity(0.3),
        
        overlay: Color.black.opacity(0.6)
    )
}

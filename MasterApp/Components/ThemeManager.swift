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
        background: .white,
        surface: Color(.systemGray6),
        elevatedSurface: .white,
        
        textPrimary: .black,
        textSecondary: .gray,
        textInverse: .white,
        
        primary: .blue,
        primaryVariant: .blue.opacity(0.8),
        secondary: .purple,
        
        buttonPrimaryBackground: .blue,
        buttonPrimaryText: .white,
        
        buttonSecondaryBackground: Color.gray.opacity(0.15),
        buttonSecondaryText: .black,
        
        buttonDisabledBackground: Color.gray.opacity(0.2),
        buttonDisabledText: .gray,
        
        success: .green,
        warning: .orange,
        error: .red,
        info: .cyan,
        
        border: Color.gray.opacity(0.3),
        divider: Color.gray.opacity(0.2),
        
        overlay: Color.black.opacity(0.4)
    )
}

extension Theme {
    static let dark = Theme(
        background: .black,
        surface: Color(.systemGray5),
        elevatedSurface: Color(.systemGray6),
        
        textPrimary: .white,
        textSecondary: .gray,
        textInverse: .black,
        
        primary: .blue,
        primaryVariant: .blue.opacity(0.7),
        secondary: .purple,
        
        buttonPrimaryBackground: .blue,
        buttonPrimaryText: .white,
        
        buttonSecondaryBackground: Color.white.opacity(0.1),
        buttonSecondaryText: .white,
        
        buttonDisabledBackground: Color.gray.opacity(0.3),
        buttonDisabledText: .gray,
        
        success: .green,
        warning: .orange,
        error: .red,
        info: .cyan,
        
        border: Color.gray.opacity(0.4),
        divider: Color.gray.opacity(0.3),
        
        overlay: Color.black.opacity(0.6)
    )
}

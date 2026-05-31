import SwiftUI

struct ThemeManager: Theme {
    static let shared: Theme = ThemeManager()
    private init() {}

    let background: Color = .white
    let textPrimary: Color = .black
}

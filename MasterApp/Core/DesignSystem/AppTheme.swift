import SwiftUI

struct AppTheme: Theme {
    let background: Color
    let textPrimary: Color
    let accent: Color

    static let light = AppTheme(
        background: .white,
        textPrimary: .black,
        accent: .blue
    )

    static let dark = AppTheme(
        background: .black,
        textPrimary: .white,
        accent: .blue
    )
}

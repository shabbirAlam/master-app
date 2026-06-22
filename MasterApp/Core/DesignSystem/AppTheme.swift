import SwiftUI

struct AppTheme: Theme {
    let background: Color
    let textPrimary: Color
    let accent: Color
    let boardLight: Color
    let boardDark: Color

    static let light = AppTheme(
        background: Color(red: 0.98, green: 0.97, blue: 0.95),
        textPrimary: Color(red: 0.15, green: 0.15, blue: 0.15),
        accent: Color(red: 0.25, green: 0.45, blue: 0.85),
        boardLight: Color(red: 0.94, green: 0.91, blue: 0.84),
        boardDark: Color(red: 0.56, green: 0.40, blue: 0.24)
    )

    static let dark = AppTheme(
        background: Color(red: 0.12, green: 0.12, blue: 0.14),
        textPrimary: Color(red: 0.92, green: 0.92, blue: 0.94),
        accent: Color(red: 0.40, green: 0.60, blue: 1.00),
        boardLight: Color(red: 0.76, green: 0.70, blue: 0.50),
        boardDark: Color(red: 0.30, green: 0.20, blue: 0.10)
    )
}

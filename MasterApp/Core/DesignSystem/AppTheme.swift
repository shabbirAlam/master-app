import SwiftUI

extension Color {
    /// Creates a color from a hex string such as `"#4073D9"` or `"4073D9"`.
    /// - Parameter hex: The hexadecimal RGB string; invalid input yields black.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let value = UInt(hex, radix: 16) ?? 0
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

/// The app's concrete theme with light and dark variants built from hex colors.
struct AppTheme: Theme {
    let background: Color
    let textPrimary: Color
    let accent: Color
    let boardLight: Color
    let boardDark: Color

    /// The light appearance theme.
    static let light = AppTheme(
        background: Color(hex: "#FAF7F2"),
        textPrimary: Color(hex: "#262626"),
        accent: Color(hex: "#4073D9"),
        boardLight: Color(hex: "#F0E8D6"),
        boardDark: Color(hex: "#AD8A61")
    )

    /// The dark appearance theme.
    static let dark = AppTheme(
        background: Color(hex: "#1F1F24"),
        textPrimary: Color(hex: "#EBEBF0"),
        accent: Color(hex: "#6699FF"),
        boardLight: Color(hex: "#C2B380"),
        boardDark: Color(hex: "#4D331A")
    )
}

import SwiftUI

/// Design-system color palette abstraction, enabling light/dark and
/// testable theme variants.
protocol Theme: Sendable {
    /// The main background color for screens.
    var background: Color { get }
    /// The primary text color.
    var textPrimary: Color { get }
    /// The accent color used for highlights and interactive elements.
    var accent: Color { get }
    /// Light square color for the chess board.
    var boardLight: Color { get }
    /// Dark square color for the chess board.
    var boardDark: Color { get }
}

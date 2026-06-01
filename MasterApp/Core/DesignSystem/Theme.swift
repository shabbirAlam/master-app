import SwiftUI

protocol Theme: Sendable {
    var background: Color { get }
    var textPrimary: Color { get }
    var accent: Color { get }
}

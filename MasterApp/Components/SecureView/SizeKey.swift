import SwiftUI

/// Preference key used to propagate the rendered size of the secure content
/// so its hosting controller can be sized to match.
struct SizeKey: PreferenceKey {
    /// Default size before any preference is reported.
    static var defaultValue: CGSize = .zero
    /// Combines preferences by keeping the latest reported value.
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

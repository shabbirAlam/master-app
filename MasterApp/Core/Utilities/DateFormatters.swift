import Foundation

/// Shared, reusable `DateFormatter` instances to avoid repeated allocation.
enum DateFormatters {
    /// Formats dates with medium date style and short time style (e.g. "Aug 25, 2026 at 3:04 PM").
    static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

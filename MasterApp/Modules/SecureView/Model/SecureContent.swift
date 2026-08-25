import Foundation

/// Sensitive content displayed inside the snapshot-preventing secure view.
struct SecureContent: Identifiable, Hashable {
    /// Unique identity of the content.
    let id = UUID()
    /// The protected message text.
    let message: String
}

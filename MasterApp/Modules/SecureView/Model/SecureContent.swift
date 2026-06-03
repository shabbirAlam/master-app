import Foundation
import Observation

struct SecureContent: Identifiable, Hashable {
    let id = UUID()
    let message: String
}

@MainActor
@Observable
final class SecureViewModel {
    private(set) var content: SecureContent

    init(content: SecureContent = SecureContent(message: "This is secure view")) {
        self.content = content
    }
}

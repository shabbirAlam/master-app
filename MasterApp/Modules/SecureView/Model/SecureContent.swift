import Combine
import Foundation

struct SecureContent: Identifiable, Hashable {
    let id = UUID()
    let message: String
}

@MainActor
final class SecureViewModel: ObservableObject {
    @Published private(set) var content: SecureContent

    init(content: SecureContent = SecureContent(message: "This is secure view")) {
        self.content = content
    }
}

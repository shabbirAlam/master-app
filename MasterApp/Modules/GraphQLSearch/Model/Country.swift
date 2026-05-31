import Foundation

struct Country: Codable, Hashable, Identifiable {
    let code: String
    let name: String
    let capital: String?

    var id: String { code }
}

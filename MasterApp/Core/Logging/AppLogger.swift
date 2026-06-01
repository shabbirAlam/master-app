import Foundation
import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.masterapp"

    static let network = Logger(subsystem: subsystem, category: "network")
    static let repository = Logger(subsystem: subsystem, category: "repository")
    static let service = Logger(subsystem: subsystem, category: "service")
    static let viewModel = Logger(subsystem: subsystem, category: "viewmodel")
    static let view = Logger(subsystem: subsystem, category: "view")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let secure = Logger(subsystem: subsystem, category: "secure")
    static let app = Logger(subsystem: subsystem, category: "app")
}

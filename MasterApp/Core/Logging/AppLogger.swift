import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.masterapp"

    enum Level {
        case debug
        case info
        case notice
        case warning
        case error
        case critical

        fileprivate var osLogType: OSLogType {
            switch self {
            case .debug: .debug
            case .info: .info
            case .notice: .default
            case .warning: .error
            case .error: .error
            case .critical: .fault
            }
        }
    }

    struct Category {
        private let logger: Logger

        fileprivate init(category: String) {
            self.logger = Logger(subsystem: AppLogger.subsystem, category: category)
        }

        func log(_ message: String, _ level: Level = .debug) {
#if DEBUG
            logger.log(level: level.osLogType, "\(message, privacy: .public)")
#endif
        }
    }

    static let network = Category(category: "Network")
    static let repository = Category(category: "Repository")
    static let service = Category(category: "Service")
    static let viewModel = Category(category: "ViewModel")
    static let view = Category(category: "View")
    static let auth = Category(category: "Auth")
    static let secure = Category(category: "Secure")
    static let app = Category(category: "App")
}

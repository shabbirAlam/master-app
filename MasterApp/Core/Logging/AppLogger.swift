import OSLog

/// Centralized structured logging facade built on top of `os.Logger`.
///
/// Usage: `AppLogger.viewModel.log("state updated", .info)`
enum AppLogger {
    /// The logging subsystem derived from the app's bundle identifier.
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.masterapp"

    /// Severity levels mapped onto `OSLogType` values.
    enum Level {
        /// Verbose diagnostic information (debug builds only).
        case debug
        /// Routine operational information.
        case info
        /// Default-level notices.
        case notice
        /// Potential problems that may require attention.
        case warning
        /// Errors that prevented an operation from completing.
        case error
        /// Critical faults indicating app-level failures.
        case critical

        /// Maps the level to the corresponding `OSLogType`.
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

    /// A named logging category backed by its own `Logger` instance.
    struct Category: Sendable {
        /// The underlying `os.Logger`.
        private let logger: Logger

        /// Creates a category with the given name.
        /// - Parameter category: The human-readable category name.
        fileprivate init(category: String) {
            self.logger = Logger(subsystem: AppLogger.subsystem, category: category)
        }

        /// Logs a message at the specified level.
        ///
        /// Messages are only emitted in `DEBUG` builds and include the source
        /// file, line, and function name. The interpolated values are marked
        /// public for visibility in Console; avoid logging sensitive data.
        ///
        /// - Parameters:
        ///   - message: The message to log.
        ///   - level: The severity level (defaults to `.debug`).
        ///   - file: The source file (captured automatically).
        ///   - function: The calling function (captured automatically).
        ///   - line: The source line (captured automatically).
        func log(_ message: String, _ level: Level = .debug, file: String = #file, function: String = #function, line: Int = #line) {
#if DEBUG
            let filename = (file as NSString).lastPathComponent
            logger.log(level: level.osLogType, "[\(filename):\(line) \(function)] \(message, privacy: .public)")
#endif
        }
    }

    /// Logging category for network operations.
    static let network = Category(category: "Network")
    /// Logging category for repository layer events.
    static let repository = Category(category: "Repository")
    /// Logging category for service layer events.
    static let service = Category(category: "Service")
    /// Logging category for ViewModel events.
    static let viewModel = Category(category: "ViewModel")
    /// Logging category for view-level events.
    static let view = Category(category: "View")
    /// Logging category for authentication flows.
    static let auth = Category(category: "Auth")
    /// Logging category for secure-content handling.
    static let secure = Category(category: "Secure")
    /// Logging category for chess AI interactions.
    static let chessAI = Category(category: "ChessAI")
    /// Logging category for app lifecycle events.
    static let app = Category(category: "App")
}

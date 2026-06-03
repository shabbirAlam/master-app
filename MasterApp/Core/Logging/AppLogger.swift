import Foundation
import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.masterapp"
    private static let logger = Logger(subsystem: subsystem, category: "AppLogger")

    enum LogLevel {
        case debug, error, info, warning, notice, critical
    }

    static func log(_ message: String, level: LogLevel = .debug) {
#if DEBUG
        switch level {
        case .debug:
            logger.debug("\(message, privacy: .private)")
        case .error:
            logger.error("\(message, privacy: .private)")
        case .info:
            logger.info("\(message, privacy: .private)")
        case .warning:
            logger.warning("\(message, privacy: .private)")
        case .notice:
            logger.notice("\(message, privacy: .private)")
        case .critical:
            logger.critical("\(message, privacy: .private)")
        }
#endif // DEBUG
    }
}

import Foundation

extension Logger {

    public enum Level: Int, Comparable, CustomStringConvertible {

        case trace, debug, warning, error

        public static func < (lhs: Level, rhs: Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        public var description: String {
            switch self {
            case .trace:
                return "TRACE"
            case .debug:
                return "DEBUG"
            case .warning:
                return "WARNING"
            case .error:
                return "ERROR"
            }
        }
    }
}

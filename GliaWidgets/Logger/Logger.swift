import Foundation

/// Collects and deliver logs
public struct Logger {

    /// Defines threshold for all loggers.
    public static var threshold = Level.warning

    /// The logger name. Used for filtering different logger outputs.
    public let name: String

    /// The closure for appending logs
    public let _log: (Level, Date, ()-> Any) -> Void

    public init(
        name: String,
        log: @escaping (Level, Date, ()-> Any) -> Void
    ) {
        self.name = name
        self._log = log
    }

    public func trace(_ message: @autoclosure () -> Any, now: Date = .init()) {
        log(.trace, now: now, message: message)
    }

    public func debug(_ message: @autoclosure () -> Any, now: Date = .init()) {
        log(.debug, now: now, message: message)
    }

    public func warning(_ message: @autoclosure () -> Any, now: Date = .init()) {
        log(.warning, now: now, message: message)
    }

    public func error(_ message: @autoclosure () -> Any, now: Date = .init()) {
        log(.error, now: now, message: message)
    }

    // MARK: - Private

    private func log(
        _ level: Level,
        now: Date,
        message: () -> Any
    ) {

        guard level >= Self.threshold else { return }
        _log(level, now, message)
    }
}

extension Logger {

    public static func live(name: String) -> Self {

        let df = ISO8601DateFormatter()
        return .init(
            name: name,
            log: { level, now, message in
                print("\(df.string(from: now)) \(level) \(name) \(message())")
            }
        )
    }
}

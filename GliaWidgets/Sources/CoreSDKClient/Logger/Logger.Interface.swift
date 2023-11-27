import Foundation

extension CoreSdkClient {
    struct Logger {
        var oneTimeClosure: () -> Logger
        var prefixedClosure: (String) -> Logger
        var localLoggerClosure: () -> Logger?
        var remoteLoggerClosure: () -> Logger?
        var errorClosure: (_ object: @autoclosure () -> Any, _ file: String, _ function: String, _ line: Int) -> Void
        var warningClosure: (_ object: @autoclosure () -> Any, _ file: String, _ function: String, _ line: Int) -> Void
        var infoClosure: (_ object: @autoclosure () -> Any, _ file: String, _ function: String, _ line: Int) -> Void
        var debugClosure: (_ object: @autoclosure () -> Any, _ file: String, _ function: String, _ line: Int) -> Void
        var configureLocalLogLevelClosure: (LogLevel) throws -> Void
        var configureRemoteLogLevelClosure: (LogLevel) throws -> Void
        var reportDeprecatedMethodClosure: (_ context: String, _ file: String, _ function: String, _ line: Int) -> Void

        var oneTime: Logger {
            oneTimeClosure()
        }

        func prefixed(_ prefix: String) -> Logger {
            prefixedClosure(prefix)
        }

        func prefixed<TypeAsPrefix>(_ prefix: TypeAsPrefix.Type) -> Logger {
            prefixed("\(prefix)")
        }

        var localLogger: Logger? {
            localLoggerClosure()
        }
        var remoteLogger: Logger? {
            remoteLoggerClosure()
        }

        func error(_ object: @autoclosure () -> Any, file: String = #fileID, function: String = #function, line: Int = #line) {
            errorClosure(object(), file, function, line)
        }

        func warning(_ object: @autoclosure () -> Any, file: String = #fileID, function: String = #function, line: Int = #line) {
            warningClosure(object(), file, function, line)
        }

        func info(_ object: @autoclosure () -> Any, file: String = #fileID, function: String = #function, line: Int = #line) {
            infoClosure(object(), file, function, line)
        }

        func debug(_ object: @autoclosure () -> Any, file: String = #fileID, function: String = #function, line: Int = #line) {
            debugClosure(object(), file, function, line)
        }

        func configureLocalLogLevel(_ level: LogLevel) throws {
            try self.configureLocalLogLevelClosure(level)
        }

        func configureRemoteLogLevel(_ level: LogLevel) throws {
            try self.configureRemoteLogLevelClosure(level)
        }

        func reportDeprecatedMethod(context: String, file: String = #fileID, function: String = #function, line: Int = #line) {
            reportDeprecatedMethodClosure(context, file, function, line)
        }

        func reportDeprecatedMethod<T>(context: T.Type, file: String = #fileID, function: String = #function, line: Int = #line) {
            reportDeprecatedMethod(context: "\(context)", file: file, function: function, line: line)
        }
    }
}

extension CoreSdkClient.Logger {
    enum LoggingError: Error {
        case localLogLevelConfigurationFailure
        case remoteLogLevelConfigurationFailure
    }
}

extension CoreSdkClient.Logger {
    enum ParameterKey {
        static let widgetsSDKVersion = "client_app.widgets.version"
    }
    static let loggerParameters = [ParameterKey.widgetsSDKVersion: StaticValues.sdkVersion]
}

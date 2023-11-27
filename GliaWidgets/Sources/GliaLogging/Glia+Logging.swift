extension Glia {
    enum LoggerPhase {
        case notConfigured(CoreSdkClient.Logger)
        case configured(CoreSdkClient.Logger)
    }

    /// Logger that is used while logger from CoreSDK is not available,
    /// when for example CoreSDK is not yet configured. This is simply
    /// a wrapper around `Swift.print`.
    /// This logger could be further extended to collect logs in memory
    /// for example, and once logger configuration is to happen,
    /// collected logs could be transferred to configured logger, but
    /// this is out of scope for current implementation.
    struct NotConfiguredLogger: CoreSdkClient.Logging {
        var environment: Environment
        var localLogger: (CoreSdkClient.Logging)?
        var remoteLogger: (CoreSdkClient.Logging)?
        var oneTime: CoreSdkClient.Logging { self }

        func error(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {
            environment.print(object())
        }

        func warning(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {
            environment.print(object())
        }

        func info(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {
            environment.print(object())
        }

        func debug(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {
            environment.print(object())
        }

        func prefixed(_ prefix: String) -> CoreSdkClient.Logging {
            self
        }

        func prefixed<TypeAsPrefix>(_ prefix: TypeAsPrefix.Type) -> CoreSdkClient.Logging {
            self
        }
    }

    func setupLogging() {
        switch self.loggerPhase {
        // In case if remote logger was already configured we just early out.
        case .configured: return
        case .notConfigured: break
        }

        do {
            let logger = try environment.coreSdk.createLogger(CoreSdkClient.Logger.loggerParameters)
            // In debug mode both local and remote logs for Widgets are turned off.
            if environment.conditionalCompilation.isDebug() {
                try logger.configureLocalLogLevel(.none)
                try logger.configureRemoteLogLevel(.none)
            // In non-debug mode local logs are turned off and remote are on.
            } else {
                try logger.configureLocalLogLevel(.none)
                try logger.configureRemoteLogLevel(.info)
            }

            self.loggerPhase = .configured(logger)
        } catch {
            self.loggerPhase.logger.error("Unable to setup logger: \(error)")
        }
    }
}

extension Glia.NotConfiguredLogger {
    struct Environment {
        var print: SwiftBased.Print
    }
}

extension Glia.LoggerPhase {
    var logger: CoreSdkClient.Logger {
        switch self {
        case let .configured(logger):
            return logger
        case let .notConfigured(logger):
            return logger
        }
    }
}

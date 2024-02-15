extension Glia {
    enum LoggerPhase {
        case notConfigured(CoreSdkClient.Logger)
        case configured(CoreSdkClient.Logger)
    }
}

extension Glia.LoggerPhase {
    var logger: CoreSdkClient.Logger {
        switch self {
        case let .configured(configuredLogger):
            return configuredLogger
        case let .notConfigured(notConfiguredLogger):
            return notConfiguredLogger
        }
    }
}

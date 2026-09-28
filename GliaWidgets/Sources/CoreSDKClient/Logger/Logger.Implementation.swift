import Foundation

extension CoreSdkClient.Logger {
    static var notConfigured: Self { makeNotConfigured() }

    private static func makeNotConfigured() -> Self {
        Self(
            oneTimeClosure: makeNotConfigured,
            prefixedClosure: { _ in makeNotConfigured() },
            localLoggerClosure: { nil },
            remoteLoggerClosure: { nil },
            errorClosure: { _, _, _, _ in },
            warningClosure: { _, _, _, _ in },
            infoClosure: { _, _, _, _ in },
            debugClosure: { _, _, _, _ in },
            configureLocalLogLevelClosure: { _ in
                throw LoggingError.localLogLevelConfigurationFailure
            },
            configureRemoteLogLevelClosure: { _ in
                throw LoggingError.remoteLogLevelConfigurationFailure
            },
            reportDeprecatedMethodClosure: { _, _, _, _ in }
        )
    }
}

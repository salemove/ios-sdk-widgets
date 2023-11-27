import Foundation

#if DEBUG
extension CoreSdkClient.Logger {
    struct Mock: CoreSdkClient.Logging {
        var oneTime: CoreSdkClient.Logging { self }
        func error(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {}
        func warning(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {}
        func info(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {}
        func debug(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {}
        var localLogger: CoreSdkClient.Logging?
        var remoteLogger: CoreSdkClient.Logging?
        func prefixed(_ prefix: String) -> CoreSdkClient.Logging { self }
        func prefixed<TypeAsPrefix>(_ prefix: TypeAsPrefix.Type) -> CoreSdkClient.Logging { self }
    }
    static let mock = Self(
        oneTimeClosure: { Self(Mock()) },
        prefixedClosure: { _ in Self(Mock()) },
        localLoggerClosure: { nil },
        remoteLoggerClosure: { nil },
        errorClosure: { _, _, _, _ in },
        warningClosure: { _, _, _, _ in },
        infoClosure: { _, _, _, _ in },
        debugClosure: { _, _, _, _ in },
        configureLocalLogLevelClosure: { _ in },
        configureRemoteLogLevelClosure: { _ in },
        reportDeprecatedMethodClosure: { _, _, _, _ in }
    )
}
#endif

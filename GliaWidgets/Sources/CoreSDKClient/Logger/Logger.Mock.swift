import Foundation

#if DEBUG
extension CoreSdkClient.Logger {
    static var mock: Self { makeMock() }

    private static func makeMock() -> Self {
        Self(
            oneTimeClosure: makeMock,
            prefixedClosure: { _ in makeMock() },
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
}
#endif

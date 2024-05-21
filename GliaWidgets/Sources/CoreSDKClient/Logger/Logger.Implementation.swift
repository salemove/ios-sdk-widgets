import Foundation

extension CoreSdkClient.Logger {
    private class NotConfiguredLogger: CoreSdkClient.Logging {
        func error(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {}
        func warning(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {}
        func info(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {}
        func debug(_ object: @autoclosure () -> Any, file: String, function: String, line: Int) {}
        func prefixed(_ prefix: String) -> CoreSdkClient.Logging { self }
        func prefixed<TypeAsPrefix>(_ prefix: TypeAsPrefix.Type) -> CoreSdkClient.Logging { self }

        var localLogger: (CoreSdkClient.Logging)? { nil }
        var remoteLogger: (CoreSdkClient.Logging)? { nil }
        var oneTime: CoreSdkClient.Logging { self }
    }

    static let notConfigured = Self(NotConfiguredLogger())
}

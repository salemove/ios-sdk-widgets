import Foundation
@_spi(GliaWidgets) import GliaCoreSDK

extension Glia {
    /// Locale provider is used for retrieving remote strings for associated key
    public final class LocaleProvider {
        let locale: (String) -> String?

        private let environment: Environment

        init(
            environment: Environment = Environment(),
            locale: @escaping (String) -> String?
        ) {
            self.environment = environment
            self.locale = locale
        }
    }
}

extension Glia.LocaleProvider {
    /// Retrieves remote string value if exists
    /// - Parameter key: String value which remote string is associated with.
    /// - Returns: `String` value if exists, otherwise returns `nil`
    public func getRemoteString(_ key: String) -> String? {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "getRemoteString(_:)"
        )
        return locale(key)
    }
}

extension Glia.LocaleProvider {
    struct Environment {
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

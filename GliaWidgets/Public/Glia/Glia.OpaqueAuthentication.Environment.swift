import Foundation
import GliaCoreSDK

extension Glia.Authentication {
    struct Environment {
        var log: CoreSdkClient.Logger
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension Glia.Authentication.Environment {
    static func create(with logger: CoreSdkClient.Logger) -> Self {
        .init(log: logger)
    }
}

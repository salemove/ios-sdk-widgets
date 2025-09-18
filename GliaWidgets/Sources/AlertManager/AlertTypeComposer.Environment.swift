import Foundation
import GliaCoreSDK

extension AlertManager.AlertTypeComposer {
    struct Environment {
        let log: CoreSdkClient.Logger
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension AlertManager.AlertTypeComposer.Environment {
    static func create(with environment: AlertManager.Environment) -> Self {
        .init(log: environment.log)
    }
}

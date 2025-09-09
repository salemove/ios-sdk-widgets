import Foundation
import GliaCoreSDK

extension PushNotifications {
    struct Environment {
        let coreSdk: CoreSdkClient
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension PushNotifications.Environment {
    static func create(with environment: Glia.Environment) -> Self {
        .init(coreSdk: environment.coreSdk)
    }
}

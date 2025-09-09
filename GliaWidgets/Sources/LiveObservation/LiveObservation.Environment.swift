import Foundation
@_spi(GliaWidgets) import GliaCoreSDK

extension LiveObservation {
    struct Environment {
        let coreSdk: CoreSdkClient
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension LiveObservation.Environment {
    static func create(with environment: Glia.Environment) -> Self {
        .init(coreSdk: environment.coreSdk)
    }
}

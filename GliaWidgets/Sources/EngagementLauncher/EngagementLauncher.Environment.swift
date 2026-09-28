import Foundation
@_spi(GliaWidgets) internal import GliaCoreSDK

extension EngagementLauncher {
    struct Environment {
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

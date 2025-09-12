import Foundation
import GliaCoreSDK

extension EngagementLauncher {
    struct Environment {
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

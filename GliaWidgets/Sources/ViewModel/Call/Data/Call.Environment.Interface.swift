import Foundation
import GliaCoreSDK

extension Call {
    struct Environment {
        var audioSession: Glia.Environment.AudioSession
        var uuid: () -> UUID
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension Call.Environment {
    static func create(with environment: CallVisualizer.Coordinator.Environment) -> Self {
        .init(
            audioSession: environment.audioSession,
            uuid: environment.uuid
        )
    }

    static func create(with environment: EngagementCoordinator.Environment) -> Self {
        .init(
            audioSession: environment.audioSession,
            uuid: environment.uuid
        )
    }
}

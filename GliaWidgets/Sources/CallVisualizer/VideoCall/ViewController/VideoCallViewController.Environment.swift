import Foundation
import GliaCoreSDK

extension CallVisualizer.VideoCallViewController {
    struct Environment {
        var videoCallView: CallVisualizer.VideoCallView.Environment
        var notificationCenter: FoundationBased.NotificationCenter
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension CallVisualizer.VideoCallViewController.Environment {
    static func create(with environment: CallVisualizer.VideoCallCoordinator.Environment) -> Self {
        .init(
            videoCallView: .create(with: environment),
            notificationCenter: environment.notificationCenter
        )
    }
}

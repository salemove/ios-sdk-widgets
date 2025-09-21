import Foundation
import GliaCoreSDK

extension Survey.ViewController {
    struct Environment {
        var notificationCenter: FoundationBased.NotificationCenter
        var log: CoreSdkClient.Logger
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension Survey.ViewController.Environment {
    static func create(with environment: EngagementCoordinator.Environment) -> Self {
        .init(
            notificationCenter: environment.notificationCenter,
            log: environment.log
        )
    }
}

#if DEBUG
extension Survey.ViewController.Environment {
    static func mock(
        notificationCenter: FoundationBased.NotificationCenter = .mock,
        log: CoreSdkClient.Logger = .mock
    ) -> Self {
        .init(
            notificationCenter: notificationCenter,
            log: log
        )
    }
}
#endif

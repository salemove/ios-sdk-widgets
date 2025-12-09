import Foundation
import GliaCoreSDK

extension ChatViewController {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var viewFactory: ViewFactory
        var gcd: GCD
        @Dependency(\.widgets.snackBar) var snackBar: SnackBar
        var notificationCenter: FoundationBased.NotificationCenter
        var alertManager: AlertManager
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension ChatViewController.Environment {
    static func create(
        with environment: ChatCoordinator.Environment,
        viewFactory: ViewFactory
    ) -> Self {
        .init(
            timerProviding: environment.timerProviding,
            viewFactory: viewFactory,
            gcd: environment.gcd,
            notificationCenter: environment.notificationCenter,
            alertManager: environment.alertManager
        )
    }
}

#if DEBUG
extension ChatViewController.Environment {
    static func mock(
        timerProviding: FoundationBased.Timer.Providing = .mock,
        viewFactory: ViewFactory = .mock(),
        gcd: GCD = .mock,
        notificationCenter: FoundationBased.NotificationCenter = .mock,
        alertManager: AlertManager = .mock()
    ) -> Self {
        .init(
            timerProviding: timerProviding,
            viewFactory: viewFactory,
            gcd: gcd,
            notificationCenter: notificationCenter,
            alertManager: alertManager
        )
    }
}
#endif

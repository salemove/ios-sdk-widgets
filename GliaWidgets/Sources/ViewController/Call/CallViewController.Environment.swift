import Foundation
import GliaCoreSDK

extension CallViewController {
    struct Environment {
        var viewFactory: ViewFactory
        var notificationCenter: FoundationBased.NotificationCenter
        var log: CoreSdkClient.Logger
        var timerProviding: FoundationBased.Timer.Providing
        var gcd: GCD
        @Dependency(\.widgets.snackBar) var snackBar: SnackBar
        var alertManager: AlertManager
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension CallViewController.Environment {
    static func create(
        with environment: CallCoordinator.Environment,
        viewFactory: ViewFactory
    ) -> Self {
        .init(
            viewFactory: viewFactory,
            notificationCenter: environment.notificationCenter,
            log: environment.log,
            timerProviding: environment.timerProviding,
            gcd: environment.gcd,
            alertManager: environment.alertManager
        )
    }
}

#if DEBUG
extension CallViewController.Environment {
    static func mock(
        viewFactory: ViewFactory = .mock(),
        notificationCenter: FoundationBased.NotificationCenter = .mock,
        log: CoreSdkClient.Logger = .mock,
        timerProviding: FoundationBased.Timer.Providing = .mock,
        gcd: GCD = .mock,
        alertManager: AlertManager = .mock()
    ) -> Self {
        .init(
            viewFactory: viewFactory,
            notificationCenter: notificationCenter,
            log: log,
            timerProviding: timerProviding,
            gcd: gcd,
            alertManager: alertManager
        )
    }
}
#endif

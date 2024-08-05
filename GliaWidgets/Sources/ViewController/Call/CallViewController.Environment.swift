import Foundation

extension CallViewController {
    struct Environment {
        var viewFactory: ViewFactory
        var notificationCenter: FoundationBased.NotificationCenter
        var log: CoreSdkClient.Logger
        var timerProviding: FoundationBased.Timer.Providing
        var gcd: GCD
        var snackBar: SnackBar
        var alertManager: AlertManager
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
            snackBar: environment.snackBar,
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
        snackBar: SnackBar = .mock,
        alertManager: AlertManager = .mock()
    ) -> Self {
        .init(
            viewFactory: viewFactory,
            notificationCenter: notificationCenter,
            log: log,
            timerProviding: timerProviding,
            gcd: gcd,
            snackBar: snackBar,
            alertManager: alertManager
        )
    }
}
#endif

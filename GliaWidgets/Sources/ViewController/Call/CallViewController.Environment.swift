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

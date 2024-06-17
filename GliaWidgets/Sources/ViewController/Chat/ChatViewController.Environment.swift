import Foundation

extension ChatViewController {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
        var viewFactory: ViewFactory
        var gcd: GCD
        var snackBar: SnackBar
        var notificationCenter: FoundationBased.NotificationCenter
        var alertManager: AlertManager
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
            snackBar: environment.snackBar,
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
        snackBar: SnackBar = .mock,
        notificationCenter: FoundationBased.NotificationCenter = .mock,
        alertManager: AlertManager = .mock()
    ) -> Self {
        .init(
            timerProviding: timerProviding,
            viewFactory: viewFactory,
            gcd: gcd,
            snackBar: snackBar,
            notificationCenter: notificationCenter,
            alertManager: alertManager
        )
    }
}
#endif

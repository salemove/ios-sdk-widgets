import Foundation

extension EngagementViewController {
    struct Environment {
        var viewFactory: ViewFactory
        var timerProviding: FoundationBased.Timer.Providing
        var gcd: GCD
        var notificationCenter: FoundationBased.NotificationCenter
        var alertManager: AlertManager
    }
}

extension EngagementViewController.Environment {
    static func create(with environment: ChatViewController.Environment) -> Self {
        .init(
            viewFactory: environment.viewFactory,
            timerProviding: environment.timerProviding,
            gcd: environment.gcd,
            notificationCenter: environment.notificationCenter,
            alertManager: environment.alertManager
        )
    }

    static func create(with environment: CallViewController.Environment) -> Self {
        .init(
            viewFactory: environment.viewFactory,
            timerProviding: environment.timerProviding,
            gcd: environment.gcd,
            notificationCenter: environment.notificationCenter,
            alertManager: environment.alertManager
        )
    }
}

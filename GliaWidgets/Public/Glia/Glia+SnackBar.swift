import Foundation

extension Glia {
    /// Shows snackbar over all application's views.
    ///
    /// - Parameters:
    ///   - message: A text message that will be displayed on snackbar.
    ///   - style: A style which will be applied for snackbar.
    ///
    func showSnackBar(with message: String, style: Theme.SnackBarStyle) {
        environment.snackBar.showSnackBarMessage(
            text: message,
            style: style,
            topMostViewController: GliaPresenter(
                environment: .create(
                    with: self.environment,
                    log: self.loggerPhase.logger,
                    sceneProvider: nil
                )
            ).topMostViewController,
            timerProviding: environment.timerProviding,
            gcd: environment.gcd,
            notificationCenter: environment.notificationCenter
        )
    }
}

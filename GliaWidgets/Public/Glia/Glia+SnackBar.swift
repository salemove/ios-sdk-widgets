import Foundation

extension Glia {
    /// Shows snackbar over all application's views.
    ///
    /// - Parameters:
    ///   - message: A text message that will be displayed on snackbar.
    ///   - style: A style which will be applied for snackbar.
    ///
    func showSnackBar(with message: String, style: Theme.SnackBarStyle) {
        environment.snackBar.present(
            text: message,
            style: style,
            for: GliaPresenter(
                environment: .create(
                    with: self.environment,
                    log: self.loggerPhase.logger,
                    sceneProvider: nil
                )
            ).topMostViewController,
            configuration: .default,
            timerProviding: environment.timerProviding,
            gcd: environment.gcd
        )
    }
}

import UIKit

protocol AlertPresenter: DismissalAndPresentationController where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func presentAlert(
        with conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() -> Void)?
    )
    func presentAlertAsView(
        with conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() -> Void)?
    )
    func presentConfirmation(
        with conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: @escaping () -> Void
    )
    func presentSingleActionAlert(
        with conf: SingleActionAlertConfiguration,
        accessibilityIdentifier: String,
        actionTapped: @escaping () -> Void
    )
    func presentSettingsAlert(
        with conf: SettingsAlertConfiguration,
        cancelled: (() -> Void)?
    )
}

extension AlertPresenter {
    func presentCriticalErrorAlert(
        with conf: MessageAlertConfiguration,
        accessibilityIdentifier: String? = nil,
        dismissed: (() -> Void)? = nil
    ) {
        let alert: AlertViewController = .init(
            kind: .criticalError(
                conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: dismissed
            ),
            viewFactory: viewFactory
        )
        replacePresentedOfferIfPossible(with: alert)
    }
    func presentAlert(
        with conf: MessageAlertConfiguration,
        accessibilityIdentifier: String? = nil,
        dismissed: (() -> Void)? = nil
    ) {
        let alert = AlertViewController(
            kind: .message(
                conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: dismissed
            ),
            viewFactory: viewFactory
        )
        replacePresentedOfferIfPossible(with: alert)
    }

    func presentAlertAsView(
        with conf: MessageAlertConfiguration,
        accessibilityIdentifier: String? = nil,
        dismissed: (() -> Void)? = nil
    ) {
        let alert = AlertViewController(
            kind: .message(
                conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: dismissed
            ),
            viewFactory: viewFactory
        )

        insertChild(alert)
        alert.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: alert.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor)
        ])
    }

    func presentConfirmation(
        with conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: @escaping () -> Void
    ) {
        let alert = AlertViewController(
            kind: .confirmation(
                conf,
                accessibilityIdentifier: accessibilityIdentifier,
                confirmed: confirmed
            ),
            viewFactory: viewFactory
        )
        replacePresentedOfferIfPossible(with: alert)
    }

    func presentSingleActionAlert(
        with conf: SingleActionAlertConfiguration,
        accessibilityIdentifier: String,
        actionTapped: @escaping () -> Void
    ) {
        let alert = AlertViewController(
            kind: .singleAction(
                conf,
                accessibilityIdentifier: accessibilityIdentifier,
                actionTapped: actionTapped
            ),
            viewFactory: viewFactory
        )
        replacePresentedOfferIfPossible(with: alert)
    }

    func presentSettingsAlert(
        with conf: SettingsAlertConfiguration,
        cancelled: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: conf.title,
            message: conf.message,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: conf.cancelTitle, style: .cancel, handler: { _ in
            cancelled?()
        })
        let settings = UIAlertAction(title: conf.settingsTitle, style: .default, handler: { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        })
        alert.addAction(cancel)
        alert.addAction(settings)
        present(alert, animated: true, completion: nil)
    }
}

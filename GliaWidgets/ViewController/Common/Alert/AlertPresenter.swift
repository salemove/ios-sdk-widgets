import UIKit

protocol AlertPresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func presentAlert(with conf: MessageAlertConfiguration,
                      dismissed: (() -> Void)?)
    func presentConfirmation(with conf: ConfirmationAlertConfiguration,
                             confirmed: @escaping () -> Void)
    func presentSettingsAlert(with conf: SettingsAlertConfiguration,
                              cancelled: (() -> Void)?)
}

extension AlertPresenter {
    func presentAlert(with conf: MessageAlertConfiguration,
                      dismissed: (() -> Void)? = nil) {
        let alert = AlertViewController(
            kind: .message(conf, dismissed: dismissed),
            viewFactory: viewFactory
        )
        present(alert, animated: true, completion: nil)
    }

    func presentConfirmation(with conf: ConfirmationAlertConfiguration,
                             confirmed: @escaping () -> Void) {
        let alert = AlertViewController(
            kind: .confirmation(conf, confirmed: confirmed),
            viewFactory: viewFactory
        )
        present(alert, animated: true, completion: nil)
    }

    func presentSettingsAlert(with conf: SettingsAlertConfiguration,
                              cancelled: (() -> Void)? = nil) {
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

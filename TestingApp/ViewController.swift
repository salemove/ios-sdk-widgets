import UIKit
import PureLayout
import GliaWidgets
import SalemoveSDK

class ViewController: UIViewController {
    private var settingsViewController = SettingsViewController()
    private var glia: Glia!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Glia UI testing"
        view.backgroundColor = .white

        let settingsButton = makeButton(title: "Settings",
                                        selector: #selector(settingsTapped))
        let chatButton = makeButton(title: "Chat",
                                    selector: #selector(chatTapped))

        let buttonsStackView = UIStackView(arrangedSubviews: [settingsButton, chatButton])
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 20
        view.addSubview(buttonsStackView)
        buttonsStackView.autoCenterInSuperview()
    }

    private func makeButton(title: String, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    @objc private func settingsTapped() {
        presentSettings()
    }

    @objc private func chatTapped() {
        presentChat()
    }
}

extension ViewController {
    func presentSettings() {
        let navController = UINavigationController(rootViewController: settingsViewController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }

    func presentChat() {
        let conf = settingsViewController.conf
        let queueID = settingsViewController.queueID
        let theme = settingsViewController.theme
        let visitorContext = VisitorContext(type: .page,
                                            url: "https://www.salemoveinsurance.com")

        glia = Glia(conf: conf)

        do {
            try glia.start(.chat,
                           queueID: queueID,
                           visitorContext: visitorContext,
                           using: theme)
        } catch {
            alert(message: "Failed to start.\nCheck conf.")
        }
    }

    func alert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        })))
        present(alert, animated: true, completion: nil)
    }
}

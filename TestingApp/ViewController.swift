import UIKit
import PureLayout
import GliaWidgets

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
        let theme = settingsViewController.theme

        glia = Glia(conf: conf)

        glia.start(.chat, using: theme)
    }
}

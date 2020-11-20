import UIKit
import PureLayout
import GliaWidgets

class ViewController: UIViewController {
    private var settingsViewController = SettingsViewController()
    private let gliaConf = Configuration(applicationToken: "",
                                         apiToken: "",
                                         environment: .europe,
                                         site: "")
    private var glia: Glia?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Glia UI testing"
        view.backgroundColor = .white

        glia = Glia(configuration: gliaConf)

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
        navigationController?.pushViewController(settingsViewController, animated: true)
    }

    func presentChat() {
        let theme = settingsViewController.theme
        let presenter: UIViewController = {
            if let navController = self.navigationController {
                return navController
            } else {
                return self
            }
        }()

        glia?.start(.chat, from: presenter, using: theme)
    }
}

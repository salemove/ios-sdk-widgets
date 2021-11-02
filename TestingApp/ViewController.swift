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
    }

    @IBAction private func settingsTapped() {
        presentSettings()
    }

    @IBAction private func chatTapped() {
        presentGlia(.chat)
    }

    @IBAction private func audioTapped() {
        presentGlia(.audioCall)
    }

    @IBAction private func videoTapped() {
        presentGlia(.videoCall)
    }

    @IBAction private func clearSession() {
        Glia.sharedInstance.clearVisitorSession()
    }
}

extension ViewController {
    func presentSettings() {
        let navController = UINavigationController(rootViewController: settingsViewController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }

    func presentGlia(_ engagementKind: EngagementKind) {
        let conf = settingsViewController.conf
        let queueID = settingsViewController.queueID
        let theme = settingsViewController.theme
        let visitorContext = VisitorContext(type: .page,
                                            url: "https://www.salemoveinsurance.com")
        Glia.sharedInstance.onEvent = { event in
            switch event {
            case .started:
                print("STARTED")
            case .engagementChanged(let kind):
                print("CHANGED:", kind)
            case .ended:
                print("ENDED")
            case .minimized:
                print("MINIMIZED")
            case .maximized:
                print("MAXIMIZED")
            }
        }

        do {
            try Glia.sharedInstance.start(
                engagementKind,
                configuration: conf,
                queueID: queueID,
                visitorContext: visitorContext,
                theme: theme
            )
        } catch {
            alert(message: "Failed to start\nCheck Glia parameters in Settings")
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

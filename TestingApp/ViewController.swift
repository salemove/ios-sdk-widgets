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

    @IBAction private func resumeTapped() {
        try? Glia.sharedInstance.resume()
    }

    @IBAction private func clearSessionTapped() {
        Glia.sharedInstance.clearVisitorSession()
    }

    @IBAction private func endEngagementTapped() {
        Glia.sharedInstance.endEngagement { result in
            print("End engagement operation has been executed. Result='\(result)'.")
        }
    }

    @IBAction private func hackoFileTapped() {

        try? Glia.sharedInstance.configure(
            with: settingsViewController.conf,
            queueId: settingsViewController.queueID,
            visitorContext: .init(type: .page, url: "http://glia.com")
        )

        guard
            let url = Bundle.main.url(forResource: "hacko", withExtension: "json"),
            let jsonData = try? Data(contentsOf: url),
            let config = try? JSONDecoder().decode(Glia.RemoteConfig.self, from: .init(jsonData))
        else { return }

        try? Glia.sharedInstance.startEngagementWithConfig(
            engagement: .chat,
            config: config
        )
    }

    @IBAction private func hackoRemoteTapped() {

        try? Glia.sharedInstance.configure(
            with: settingsViewController.conf,
            queueId: settingsViewController.queueID,
            visitorContext: .init(type: .page, url: "http://glia.com")
        )

        try? Glia.sharedInstance.startEngagementWithRemoteConfig(engagement: .chat)
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
                theme: theme,
                features: settingsViewController.features
            )
        } catch GliaError.engagementExists {
            alert(message: "Failed to start\nEngagement is ongoing, please use 'Resume' button")
        } catch GliaError.engagementNotExist {
            alert(message: "Failed to start\nNo ongoing engagement. Please start a new one with 'Start chat' button")
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

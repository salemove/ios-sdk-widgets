import UIKit
import PureLayout
import GliaWidgets
import SalemoveSDK

class ViewController: UIViewController {
    private var glia: Glia!

    @UserDefaultsStored(key: "configuration", defaultValue: Configuration.empty(with: .beta), coder: .jsonCoding())
    private var configuration: Configuration

    @UserDefaultsStored(key: "queueId", defaultValue: "")
    private var queueId: String

    private var theme = Theme()

    @UserDefaultsStored(key: "features", defaultValue: Features.all, coder: .rawRepresentable())
    private var features: Features

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

    @IBAction private func remoteConfigTapped() {
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)

        guard !paths.isEmpty else {
            alert(message: "Could not find any json file")
            return
        }

        let names = paths
            .compactMap(URL.init(string:))
            .compactMap {
                $0.lastPathComponent
                .components(separatedBy: ".")
                .first
            }.sorted()

        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        let action: (String) -> UIAlertAction = { fileName in
            UIAlertAction(title: fileName, style: .default) { [weak self, weak alert] _ in
                self?.applyRemoteConfig(with: fileName)
                alert?.dismiss(animated: true)
            }
        }
        names.map(action).forEach(alert.addAction)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension ViewController {
    func presentSettings() {
        let viewController = SettingsViewController(
            props: .init(
                config: configuration,
                changeConfig: { [weak self] newConfig in self?.configuration = newConfig },
                queueId: queueId,
                changeQueueId: { [weak self] newQueueId in self?.queueId = newQueueId },
                theme: theme,
                changeTheme: { [weak self] newTheme in self?.theme = newTheme },
                features: features,
                changeFeatures: { [weak self] newFeatures in self?.features = newFeatures }
            )
        )
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }

    func presentGlia(_ engagementKind: EngagementKind) {
        let visitorContext: SalemoveSDK.VisitorContext? = configuration.visitorContext
            .map(\.assetId)
            .map(SalemoveSDK.VisitorContext.AssetId.init(rawValue:))
            .map(SalemoveSDK.VisitorContext.ContextType.assetId)
            .map(SalemoveSDK.VisitorContext.init)
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
            #if DEBUG
            let pushNotifications = Configuration.PushNotifications.sandbox
            #else
            let pushNotifications = Configuration.PushNotifications.production
            #endif
            configuration.pushNotifications = pushNotifications

            try Glia.sharedInstance.start(
                engagementKind,
                configuration: configuration,
                queueID: queueId,
                visitorContext: visitorContext,
                theme: theme,
                features: features
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

    func updateConfiguration(with queryItems: [URLQueryItem]) {
        Configuration(queryItems: queryItems).map { configuration = $0 }
        queryItems.first(where: { $0.name == "queue_id"})?.value.map {
            queueId = $0
        }
    }

    func applyRemoteConfig(with name: String) {
        try? Glia.sharedInstance.configure(
            with: configuration,
            queueId: queueId,
            visitorContext: .init(type: .page, url: "http://glia.com")
        )

        guard
            let url = Bundle.main.url(forResource: name, withExtension: "json"),
            let jsonData = try? Data(contentsOf: url),
            let config = try? JSONDecoder().decode(RemoteConfiguration.self, from: .init(jsonData))
        else { return }

        try? Glia.sharedInstance.startEngagementWithConfig(
            engagement: .chat,
            uiConfig: config
        )
    }
}

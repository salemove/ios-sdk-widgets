import GliaCoreSDK
import GliaWidgets
import UIKit

class ViewController: UIViewController {
    typealias Authentication = GliaWidgets.Glia.Authentication

    @UserDefaultsStored(key: "configuration", defaultValue: Configuration.empty(with: .beta), coder: .jsonCoding())
    var configuration: Configuration

    @UserDefaultsStored(key: "queueId", defaultValue: "")
    private(set) var queueId: String

    private(set) var theme = Theme()

    // Features provided from Glia Settings for `configure` method.
    @UserDefaultsStored(key: "features", defaultValue: Features.all, coder: .rawRepresentable())
    private(set) var features: Features

    // If not `nil`, this value will be passed to deprecated
    // `Glia.sharedInstance.startEngagement(engagementKind:in:features:sceneProvider:)`
    // overwriting `features` passed initially to `Glia.sharedInstance.configure` method.
    // If not set, non-deprecated `startEngagement` will be called,
    // using `features` passed to `configure` under the hood.
    private var startEngagementFeatures: Features? {
        switch (enablingOverwriteBubbleSwitch.isOn, togglingStartEngBubbleSwitch.isOn) {
        case (false, _):
            return nil
        case (true, true):
            var features = self.features
            return features.insert(.bubbleView).memberAfterInsert
        case (true, false):
            return self.features.subtracting(.bubbleView)
        }
    }

    let visitorInfoModel = VisitorInfoModel(
        environment: .init(
            fetchVisitorInfo: GliaCore.sharedInstance.fetchVisitorInfo,
            updateVisitorInfo: GliaCore.sharedInstance.updateVisitorInfo,
            uuid: UUID.init
        )
    )

    var authentication: Authentication?
    var authTimer: Timer?
    var entryWidget: EntryWidget?
    var engagementLauncher: EngagementLauncher?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Glia UI testing"
        view.backgroundColor = .white
        setupPushHandler()
        configureAuthenticationBehaviorToggleAccessibility()
        setupStartEngagementBubbleSwitches()
    }

    // MARK: - IBOutlets

    @IBOutlet weak var visitorCodeView: UIView!
    @IBOutlet weak var entryWidgetView: UIView!
    @IBOutlet var toggleAuthenticateButton: UIButton!
    @IBOutlet var refreshAccessTokenButton: UIButton!
    @IBOutlet var configureButton: UIButton!
    @IBOutlet var secureConversationsButton: UIButton!
    @IBOutlet var autoConfigureSdkToggle: UISwitch!

    @IBOutlet var authenticationBehaviorSegmentedControl: UISegmentedControl!
    var authenticationBehavior: Authentication.Behavior {
        authenticationBehaviorSegmentedControl.selectedSegmentIndex == 0 ? .forbiddenDuringEngagement : .allowedDuringEngagement
    }

    // Switch control that enables call of deprecated
    // `Glia.sharedInstance.startEngagement(engagementKind:in:features:sceneProvider:)`
    // method with passed `startEngagementFeatures` as `features` parameter.
    @IBOutlet weak var enablingOverwriteBubbleSwitch: UISwitch!
    // Switch control that toggles bubble visibility via deprecated
    // `Glia.sharedInstance.startEngagement(engagementKind:in:features:sceneProvider:)`
    @IBOutlet weak var togglingStartEngBubbleSwitch: UISwitch!

    // MARK: - IBActions

    @IBAction private func settingsTapped() {
        presentSettings()
    }

    @IBAction private func chatTapped() {
        prepareGlia {
            self.catchingError {
                try self.engagementLauncher?.startChat()
            }
        }
    }

    @IBAction private func entryWidgetSheetTapped() {
        self.entryWidget?.show(in: self)
    }

    @IBAction private func entryWidgetEmbbededTapped() {
        self.entryWidget?.embed(in: entryWidgetView)
    }

    @IBAction private func audioTapped() {
        prepareGlia {
            self.catchingError {
                try self.engagementLauncher?.startAudioCall()
            }
        }
    }

    @IBAction private func videoTapped() {
        prepareGlia {
            self.catchingError {
                try self.engagementLauncher?.startVideoCall()
            }
        }
    }

    @IBAction private func resumeTapped() {
        try? Glia.sharedInstance.resume()
    }

    @IBAction private func secureConversationTapped() {
        prepareGlia {
            self.catchingError {
                try self.engagementLauncher?.startSecureMessaging()
            }
        }
    }

    @IBAction func refreshAccessToken() {
        showRefreshAccessToken()
    }

    @IBAction private func showSensitiveDataTapped() {
        let controller = SensitiveDataViewController()
        let navigation = UINavigationController(rootViewController: controller)
        present(navigation, animated: true)
    }

    @IBAction private func clearSessionTapped() {
        Glia.sharedInstance.clearVisitorSession { [weak self] result in
            guard case let .failure(error) = result else { return }
            self?.alert(message: "The operation couldn't be completed. '\(error)'.")
        }
    }

    @IBAction private func endEngagementTapped() {
        // Since ending of engagement is possible
        // only if such engagement exists, we need
        // to configure SDK, and only then attempt
        // to end engagement.
        prepareGlia {
            Glia.sharedInstance.endEngagement { result in
                print("End engagement operation has been executed. Result='\(result)'.")
            }
        }
    }
}

// MARK: - Internal
extension ViewController {
    func updateConfiguration(with queryItems: [URLQueryItem]) {
        Configuration(queryItems: queryItems).map { configuration = $0 }
        queryItems.first(where: { $0.name == "queue_id" })?.value.map {
            queueId = $0
        }
    }

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
}

// MARK: - Private
private extension ViewController {


    func setupPushHandler() {
        GliaCore.sharedInstance.pushNotifications.handler = { [weak self] push in
            switch (push.type, push.timing) {
            // Open chat transcript only when the push notification has come
            // when the app is on the background and the visitor has pressed
            // on the notification banner.
            case (.chatMessage, .background), (.queueMessage, .background):
                guard self?.presentedViewController == nil else { return }

                self?.prepareGlia {
                    do {
                        try self?.engagementLauncher?.startSecureMessaging()
                    } catch GliaError.engagementExists {
                        try? Glia.sharedInstance.resume()
                    } catch {
                        self?.showErrorAlert(using: error)
                    }
                }
            default:
                break
            }
        }
    }

    func renderStartEngagementBubbleSwitches() {
        if let startEngagementFeatures {
            self.enablingOverwriteBubbleSwitch.isOn = true
            self.togglingStartEngBubbleSwitch.isEnabled = true
            self.togglingStartEngBubbleSwitch.isOn = startEngagementFeatures.contains(.bubbleView)
        } else {
            self.enablingOverwriteBubbleSwitch.isOn = false
            self.togglingStartEngBubbleSwitch.isEnabled = false
        }
    }

    func setupStartEngagementBubbleSwitches() {
        [self.enablingOverwriteBubbleSwitch, self.togglingStartEngBubbleSwitch]
            .forEach { uiSwitch in
                uiSwitch.addTarget(
                    self,
                    action: #selector(handleStartEngagementBubbleSwitchChange),
                    for: .valueChanged
                )
            }
        renderStartEngagementBubbleSwitches()
    }

    @objc
    func handleStartEngagementBubbleSwitchChange(_: UISwitch) {
        renderStartEngagementBubbleSwitches()
    }
}

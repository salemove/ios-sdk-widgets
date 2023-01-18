import UIKit
import PureLayout
import GliaWidgets
import SalemoveSDK

class ViewController: UIViewController {
    typealias Authentication = GliaWidgets.Glia.Authentication
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

        Glia.sharedInstance.callVisualizer.presenter = { self }
    }
    @IBOutlet weak var visitorCodeView: UIView!

    @IBOutlet var toggleAuthenticateButton: UIButton!

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

    @IBAction private func presentVisitorCodeAsAlertTapped() {
        showVisitorCodeAlert()
    }

    @IBAction private func embedVisitorCodeViewTapped() {
        showVisitorCodeEmbeddedView()
    }

    @IBAction private func configureSDKTapped() {
        configureSDK()
    }

    @IBAction private func endEngagementTapped() {
        self.catchingError {
            // Since ending of engagement is possible
            // only if such engagement exists, we need
            // to configure SDK, and only then attempt
            // to end engagement.
            try Glia.sharedInstance.configure(
                with: configuration,
                queueId: queueId,
                visitorContext: (configuration.visitorContext?.assetId)
                    .map(VisitorContext.AssetId.init(rawValue:))
                    .map(VisitorContext.ContextType.assetId)
                    .map(VisitorContext.init(_:))
            ) {
                Glia.sharedInstance.endEngagement { result in
                    print("End engagement operation has been executed. Result='\(result)'.")
                }
            }
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
                self?.showEngagementKindActionSheet { kind in
                    self?.startEngagement(with: kind, config: fileName)
                }
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

    func showVisitorCodeEmbeddedView() {
        Glia.sharedInstance.callVisualizer.showVisitorCodeViewController(by: .embedded(visitorCodeView))
    }

    func showVisitorCodeAlert() {
        Glia.sharedInstance.callVisualizer.showVisitorCodeViewController(by: .alert(self))
    }

    func configureSDK() {
        try? Glia.sharedInstance.configure(
            with: configuration,
            queueId: queueId,
            visitorContext: nil) {
                debugPrint("SDK has been configured")
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
        queryItems.first(where: { $0.name == "queue_id" })?.value.map {
            queueId = $0
        }
    }

    /// Shows alert with engagement kinds.
    /// - Parameter completion: Completion handler to be called on engagement kind selection.
    func showEngagementKindActionSheet(completion: @escaping (EngagementKind) -> Void) {
        let data: [(EngagementKind, String)] = [
            (.chat, "Chat"),
            (.audioCall, "Audio"),
            (.videoCall, "Video")
        ]
        let alert = UIAlertController(
            title: "Choose engagement type",
            message: nil,
            preferredStyle: .actionSheet
        )
        let action: ((kind: EngagementKind, title: String)) -> UIAlertAction = { data  in
            UIAlertAction(title: data.title, style: .default) { [weak alert] _ in
                completion(data.kind)
                alert?.dismiss(animated: true)
            }
        }
        data.map(action).forEach(alert.addAction)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func startEngagement(with kind: EngagementKind, config name: String) {
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
            engagement: kind,
            uiConfig: config
        )
    }
}

extension ViewController {
    static func authentication() throws -> Authentication {
        try Glia.sharedInstance.authentication(with: .forbiddenDuringEngagement)
    }

    @IBAction private func toggleAuthentication() {
        catchingError {
            try Glia.sharedInstance.configure(
                with: configuration,
                queueId: queueId,
                visitorContext: (configuration.visitorContext?.assetId)
                    .map(VisitorContext.AssetId.init(rawValue:))
                    .map(VisitorContext.ContextType.assetId)
                    .map(VisitorContext.init(_:))
            ) { [weak self] in
                guard let self = self else { return }
                self.catchingError {
                    let authentication = try Self.authentication()
                    switch authentication.isAuthenticated {
                    case false:
                        self.showAuthorize(with: authentication)
                    case true:
                        self.showDeauthorize(
                            authorization: authentication,
                            from: self.toggleAuthenticateButton
                        )
                    }
                }
            }
        }
    }

    func showAuthorize(with authentication: Authentication) {
        let alertController = UIAlertController(
            title: nil,
            message: "Add JWT authentication token",
            preferredStyle: .alert
        )

        class TextFieldDelegate: NSObject {
            var textChanged: (String) -> Void

            init(textChanged: @escaping (String) -> Void) {
                self.textChanged = textChanged
            }

            @objc func handleTextChanged(textField: UITextField) {
                self.textChanged(textField.text ?? "")
            }

            deinit {
                print("TextFieldDelegate from UIAlertController has been deinitialized.")
            }
        }

        var enteredJwt: String = ""

        let createAuthorizationAction = UIAlertAction(
            title: "Create Authentication",
            style: .default
        ) { _ in
            authentication.authenticate(with: enteredJwt) { [weak self] result in
                switch result {
                case .success:
                    self?.renderAuthenticatedState(isAuthenticated: true)
                case let .failure(error):
                    self?.renderAuthenticatedState(isAuthenticated: false)
                    self?.alert(message: error.reason)
                }
            }

        }

        let isEmptyJwt = { enteredJwt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        createAuthorizationAction.isEnabled = !isEmptyJwt()
        createAuthorizationAction.accessibilityIdentifier = "create_authentication_alert_button"

        let jwtTextFieldDelegate = TextFieldDelegate(
            textChanged: { [weak createAuthorizationAction] text in
                enteredJwt = text
                createAuthorizationAction?.isEnabled = !isEmptyJwt()
            }
        )

        alertController.addTextField(
            configurationHandler: { textField in
                textField.accessibilityIdentifier = "authentication_id_token_textfield"
                textField.addTarget(
                    jwtTextFieldDelegate,
                    action: #selector(jwtTextFieldDelegate.handleTextChanged(textField:)),
                    for: .editingChanged
                )
            }
        )

        let cancel = UIAlertAction(
            title: "Cancel",
            style: .cancel
        ) { [jwtTextFieldDelegate] _ in
            // Keep strong reference to text field delegate
            // while alert is visible to keep it alive.
            _ = jwtTextFieldDelegate
        }
        cancel.accessibilityIdentifier = "cancel_authentication_alert_button"

        alertController.addAction(createAuthorizationAction)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }

    func showDeauthorize(
        authorization: Authentication,
        from originView: UIView
    ) {
        let actionSheet = UIAlertController(
            title: "Remove Authentication",
            message: nil,
            preferredStyle: .actionSheet
        )
        let deauthenticateAction = UIAlertAction(
            title: "Deauthenticate",
            style: .destructive
        ) { _ in
            authorization.deauthenticate { [weak self] result in
                switch result {
                case .success:
                    self?.renderAuthenticatedState(isAuthenticated: false)
                case let .failure(error):
                    self?.alert(message: error.reason)
                }
            }
        }

        deauthenticateAction.accessibilityIdentifier = "deauthenticate_action_sheet_button"

        actionSheet.addAction(deauthenticateAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.accessibilityIdentifier = "cancel_deauthenticate_action_sheet_button"
        actionSheet.addAction(cancelAction)

        actionSheet.presented(
            in: self,
            popoverSettings: .init(sourceRect: originView.frame)
        )
    }

    func renderAuthenticatedState(isAuthenticated: Bool) {
        self.toggleAuthenticateButton.setTitle(
            isAuthenticated ? "Deauthenticate" : "Authenticate",
            for: .normal
        )
    }

    /// Report any thrown error via UIAlertController.
    /// - Parameter throwing: closure wrapping throwing code.
    func catchingError(_ throwing: () throws -> Void) {
        do {
            try throwing()
        } catch let error as GliaCoreError {
            self.alert(message: error.reason)
        } catch let error as ConfigurationError {
            self.alert(message: "Configuration error: '\(error)'.")
        } catch {
            self.alert(message: error.localizedDescription)
        }
    }
}

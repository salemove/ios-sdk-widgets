import UIKit
import PureLayout
import GliaWidgets
import GliaCoreSDK

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
        setupPushHandler()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
#if DEBUG
        if motion == .motionShake {
            let playbook = PlaybookViewController()
            let navigationController = UINavigationController(rootViewController: playbook)
            navigationController.modalPresentationStyle = .overFullScreen
            playbook.title = "Playbook"
            present(navigationController, animated: true)
            playbook.navigationItem.leftBarButtonItem = .init(title: "Close", style: .plain, target: self, action: #selector(pop))
        }
#endif
    }

    @IBOutlet weak var visitorCodeView: UIView!
    @IBOutlet var toggleAuthenticateButton: UIButton!
    @IBOutlet var configureButton: UIButton!
    @IBOutlet var secureConversationsButton: UIButton!

    @IBAction private func settingsTapped() {
        presentSettings()
    }

    @IBAction private func chatTapped() {
        do {
            try presentGlia(.chat)
        } catch {
            showErrorAlert(using: error)
        }
    }

    @IBAction private func audioTapped() {
        do {
            try presentGlia(.audioCall)
        } catch {
            showErrorAlert(using: error)
        }
    }

    @IBAction private func videoTapped() {
        do {
            try presentGlia(.videoCall)
        } catch {
            showErrorAlert(using: error)
        }
    }

    @IBAction private func resumeTapped() {
        try? Glia.sharedInstance.resume()
    }

    @IBAction private func secureConversationTapped() {
        do {
            try presentGlia(.messaging())
        } catch {
            showErrorAlert(using: error)
        }
    }

    private func showErrorAlert(using error: Error) {
        guard let gliaError = error as? GliaError else { return }

        switch error {
        case GliaError.engagementExists:
            alert(message: "Failed to start\nEngagement is ongoing, please use 'Resume' button")
        case GliaError.engagementNotExist:
            alert(message: "Failed to start\nNo ongoing engagement. Please start a new one with 'Start chat' button")
        case GliaError.callVisualizerEngagementExists:
            alert(message: "Failed to start\nCall Visualizer engagement is ongoing")
        default:
            alert(message: "Failed to start\nCheck Glia parameters in Settings")

        }
    }

    @IBAction private func clearSessionTapped() {
        Glia.sharedInstance.clearVisitorSession { [weak self] result in
            guard case let .failure(error) = result else { return }
            self?.alert(message: "The operation couldn't be completed. '\(error)'.")
        }
    }

    @IBAction private func configureSDKTapped() {
        showRemoteConfigAlert { [weak self] fileName in
            var config: RemoteConfiguration?
            if let fileName = fileName {
                config = self?.retrieveRemoteConfiguration(fileName)
            }
            self?.configureSDK(uiConfig: config)
        }
    }

    @IBAction private func endEngagementTapped() {
        self.catchingError {
            // Since ending of engagement is possible
            // only if such engagement exists, we need
            // to configure SDK, and only then attempt
            // to end engagement.
            try Glia.sharedInstance.configure(
                with: configuration,
                queueId: queueId
            ) {
                Glia.sharedInstance.endEngagement { result in
                    print("End engagement operation has been executed. Result='\(result)'.")
                }
            }
        }
    }

    @IBAction private func remoteConfigTapped() {
        showRemoteConfigAlert { [weak self] fileName in
            guard let fileName = fileName else {
                self?.alert(message: "Could not find any json file")
                return
            }
            self?.showEngagementKindActionSheet { kind in
                self?.startEngagement(with: kind, config: fileName)
            }
        }
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

    func presentGlia(_ engagementKind: EngagementKind) throws {
        let visitorContext: GliaCoreSDK.VisitorContext? = configuration.visitorContext
            .map(\.assetId)
            .map(GliaCoreSDK.VisitorContext.AssetId.init(rawValue:))
            .map(GliaCoreSDK.VisitorContext.ContextType.assetId)
            .map(GliaCoreSDK.VisitorContext.init)

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
            @unknown default:
                print("UNknown case='\(event)'.")
            }
        }

        #if DEBUG
        let pushNotifications = Configuration.PushNotifications.sandbox
        #else
        let pushNotifications = Configuration.PushNotifications.disabled
        #endif
        configuration.pushNotifications = pushNotifications

        try Glia.sharedInstance.start(
            engagementKind,
            configuration: configuration,
            queueID: queueId,
            theme: theme,
            features: features
        )
    }

    func configureSDK(uiConfig: RemoteConfiguration?) {
        let originalTitle = configureButton.title(for: .normal)
        let originalIdentifier = configureButton.accessibilityIdentifier
        configureButton.setTitle("Configuring ...", for: .normal)
        configureButton.accessibilityIdentifier = "main_configure_sdk_button_loading"

        let completion = { [weak self] printable in
            self?.configureButton.setTitle(originalTitle, for: .normal)
            self?.configureButton.accessibilityIdentifier = originalIdentifier
            debugPrint(printable)
        }
        do {
            try Glia.sharedInstance.configure(
                with: configuration,
                queueId: queueId,
                uiConfig: uiConfig
            ) {
                completion("SDK has been configured")
            }
        } catch {
            completion(error)
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
            (.videoCall, "Video"),
            (.messaging(), "Messaging")
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
            queueId: queueId
        )

        guard let config = retrieveRemoteConfiguration(name) else { return }

        try? Glia.sharedInstance.startEngagementWithConfig(
            engagement: kind,
            uiConfig: config
        )
    }

    private func jsonNames() -> [String] {
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: "UnifiedUI")
        return paths
            .compactMap(URL.init(string:))
            .compactMap {
                $0.lastPathComponent
                    .components(separatedBy: ".")
                    .first
            }.sorted()
    }

    func showRemoteConfigAlert(_ completion: @escaping (String?) -> Void) {
        let names = jsonNames()
        guard !names.isEmpty else {
            completion(nil)
            return
        }

        let alert = UIAlertController(
            title: "Remote configuration",
            message: "Selected config will be applied",
            preferredStyle: .actionSheet
        )
        let action: (String) -> UIAlertAction = { fileName in
            UIAlertAction(title: fileName, style: .default) { [weak alert] _ in
                completion(fileName)
                alert?.dismiss(animated: true)
            }
        }
        names.map(action).forEach(alert.addAction)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func retrieveRemoteConfiguration(_ fileName: String) -> RemoteConfiguration? {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let jsonData = try? Data(contentsOf: url),
            let config = try? JSONDecoder().decode(RemoteConfiguration.self, from: .init(jsonData))
        else {
            alert(message: "Could not decode RemoteConfiguration.")
            return nil
        }
        return config
    }

    func setupPushHandler() {
        let waitForActiveEngagement = GliaCore.sharedInstance.waitForActiveEngagement(completion:)
        GliaCore.sharedInstance.pushNotifications.handler = { [weak self] push in
            switch (push.type, push.timing) {
            // Open chat transcript only when the push notification has come
            // when the app is on the background and the visitor has pressed
            // on the notification banner.
            case (.chatMessage, .background), (.queueMessage, .background):
                guard self?.presentedViewController == nil else { return }

                do {
                    try self?.presentGlia(.messaging(.chatTranscript))
                } catch GliaError.engagementExists {
                    try? Glia.sharedInstance.resume()
                } catch {
                    self?.showErrorAlert(using: error)
                }
            default:
                break
            }
        }
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
                queueId: queueId
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
        var enteredAccessToken: String = ""

        let createAuthorizationAction = UIAlertAction(
            title: "Create Authentication",
            style: .default
        ) { _ in
            authentication.authenticate(
                with: enteredJwt,
                accessToken: enteredAccessToken.isEmpty ? nil : enteredAccessToken
            ) { [weak self] result in
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

        let accessTokenTextFieldDelegate = TextFieldDelegate(
            textChanged: { text in
                enteredAccessToken = text
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

        alertController.addTextField(
            configurationHandler: { textField in
                textField.placeholder = "(Optional) Access token"
                textField.accessibilityIdentifier = "authentication_access_token_textfield"
                textField.addTarget(
                    accessTokenTextFieldDelegate,
                    action: #selector(accessTokenTextFieldDelegate.handleTextChanged(textField:)),
                    for: .editingChanged
                )
            }
        )

        let cancel = UIAlertAction(
            title: "Cancel",
            style: .cancel
        ) { [jwtTextFieldDelegate, accessTokenTextFieldDelegate] _ in
            // Keep strong reference to text field delegate
            // while alert is visible to keep it alive.
            _ = jwtTextFieldDelegate
            _ = accessTokenTextFieldDelegate
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
        } catch let error as GliaError {
            self.alert(message: "The operation couldn't be completed. '\(error)'.")
        } catch {
            self.alert(message: error.localizedDescription)
        }
    }

    @objc func pop() {
        presentedViewController?.dismiss(animated: true)
    }
}

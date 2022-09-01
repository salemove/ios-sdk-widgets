import UIKit
import PureLayout
import GliaWidgets
import SalemoveSDK

class ViewController: UIViewController {
    typealias Authentication = GliaWidgets.Glia.Authentication

    private var glia: Glia!
    private var authentication: Authentication?

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

    @IBAction private func endEngagementTapped() {
        Glia.sharedInstance.endEngagement { result in
            print("End engagement operation has been executed. Result='\(result)'.")
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
}

extension ViewController {
    @IBAction private func toggleAuthentication() {
        do {
            try Glia.sharedInstance.configure(
                with: configuration,
                queueId: queueId,
                visitorContext: (configuration.visitorContext?.assetId)
                    .map(VisitorContext.AssetId.init(rawValue:))
                    .map(VisitorContext.ContextType.assetId)
                    .map(VisitorContext.init(_:))
            ) { [weak self] in
                guard let self = self else { return }
                switch self.authentication {
                case .none:
                    self.showAuthorize()
                case let .some(auth):
                    self.showDeauthorize(
                        authorization: auth,
                        from: self.toggleAuthenticateButton
                    )
                }
            }
        } catch let error as SalemoveError {
            self.alert(message: error.reason)
            return
        } catch {
            self.alert(message: error.localizedDescription)
            return
        }
    }

    func showAuthorize() {
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
            title: "Create Autorization",
            style: .default
        ) { _ in
            do {
                let auth = try Glia.sharedInstance.authentication()
                auth.authenticate(with: enteredJwt) { [weak self] result in
                    switch result {
                    case .success:
                        self?.authentication = auth
                        self?.renderAuthenticatedState(isAuthenticated: true)
                    case let .failure(error):
                        self?.renderAuthenticatedState(isAuthenticated: false)
                        self?.authentication = nil
                        self?.alert(message: error.reason)
                    }
                }
            } catch let error as SalemoveError {
                self.alert(message: error.reason)
            } catch {
                self.alert(message: error.localizedDescription)
            }
        }

        let isEmptyJwt = { enteredJwt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        createAuthorizationAction.isEnabled = !isEmptyJwt()

        let jwtTextFieldDelegate = TextFieldDelegate(
            textChanged: { [weak createAuthorizationAction] text in
                enteredJwt = text
                createAuthorizationAction?.isEnabled = !isEmptyJwt()
            }
        )

        alertController.addTextField(
            configurationHandler: { textField in
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
                    self?.authentication = nil
                    self?.renderAuthenticatedState(isAuthenticated: false)
                case let .failure(error):
                    self?.alert(message: error.reason)
                }
            }
        }
        actionSheet.addAction(deauthenticateAction)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

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
}

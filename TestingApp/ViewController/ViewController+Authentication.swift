import UIKit
import GliaWidgets

extension ViewController {
    @IBAction private func toggleAuthentication() {
        let authenticate = {
            self.catchingError {
                let authentication = try Glia.sharedInstance.authentication(with: self.authenticationBehavior)
                switch authentication.isAuthenticated {
                case false:
                    self.authentication = authentication
                    self.showAuthorize(with: authentication)
                case true:
                    self.showDeauthorize(
                        authorization: authentication,
                        from: self.toggleAuthenticateButton
                    )
                }
            }
        }

        if autoConfigureSdkToggle.isOn {
            configureSDK(uiConfigName: nil) { [weak self] result in
                switch result {
                case .success:
                    authenticate()
                case let .failure(error):
                    self?.showErrorAlert(using: error)
                }
            }
        } else {
            authenticate()
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
                    self?.startAuthTimer()
                case let .failure(error):
                    self?.renderAuthenticatedState(isAuthenticated: false)
                    self?.alert(message: error.reason)
                }
            }
        }

        createAuthorizationAction.accessibilityIdentifier = "create_authentication_alert_button"

        let jwtTextFieldDelegate = TextFieldDelegate(
            textChanged: { text in
                enteredJwt = text
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

    func showRefreshAccessToken() {
        guard let authentication else {
            print("Not authenticated")
            return
        }
        let alertController = UIAlertController(
            title: nil,
            message: "Refresh access token",
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
            title: "Refresh",
            style: .default
        ) { _ in
            authentication.refresh(
                with: enteredJwt,
                accessToken: enteredAccessToken.isEmpty ? nil : enteredAccessToken
            ) { result in
                switch result {
                case .success:
                    let message = "Access token successfully refreshed"
                    self.alert(message: message)
                case let .failure(error):
                    self.alert(message: error.reason)
                }
                self.renderAuthenticatedState(isAuthenticated: authentication.isAuthenticated)
            }
        }

        let isEmptyJwt = { enteredJwt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        createAuthorizationAction.isEnabled = !isEmptyJwt()
        createAuthorizationAction.accessibilityIdentifier = "refresh_token_alert_refresh_button"

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
                textField.accessibilityIdentifier = "authentication_refresh_token_textfield"
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
                    self?.authentication = nil
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
        authenticationBehaviorSegmentedControl.isEnabled = !isAuthenticated
        refreshAccessTokenButton.isEnabled = isAuthenticated
    }

    func configureAuthenticationBehaviorToggleAccessibility() {
        authenticationBehaviorSegmentedControl?
            .subviews
            .enumerated()
            .forEach {
                switch $0.offset {
                case 0:
                    $0.element.accessibilityIdentifier = "main_auth_behaviour_allowed"
                case 1:
                    $0.element.accessibilityIdentifier = "main_auth_behaviour_forbidden"
                default: break
                }
            }
    }

    /// We don't have a way to report back to viewController,
    /// about deauthentication because of an error. We need to
    /// check it manually so that UI renders properly.
    func startAuthTimer() {
        authTimer = Timer.scheduledTimer(
            timeInterval: 3.0,
            target: self,
            selector: #selector(checkAuthState),
            userInfo: nil,
            repeats: true
        )
    }

    func stopAuthTimer() {
        authTimer?.invalidate()
        authTimer = nil
    }

    @objc func checkAuthState() {
        guard let authentication, authentication.isAuthenticated else {
            authentication = nil
            stopAuthTimer()
            renderAuthenticatedState(isAuthenticated: false)
            return
        }
        renderAuthenticatedState(isAuthenticated: true)
    }
}

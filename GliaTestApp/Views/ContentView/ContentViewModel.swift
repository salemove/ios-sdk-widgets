import SwiftUI
import GliaWidgets

extension ContentView {
    @MainActor
    final class ViewModel: ObservableObject {
        let appState: AppState

        @Published var showError: AlertData?
        @Published var showAuthenticationAlert = false
        @Published var showRefreshTokenAlert = false
        @Published var showVisitorInfo = false
        @Published var showSensitiveData = false
        @Published var jwtToken = ""
        @Published var accessToken = ""
        @Published var configurationState: ConfigurationState = .idle
        @Published var isAuthenticated = false
        @Published var isEntryWidgetEmbedded = false
        @Published var isVisitorCodeEmbedded = false

        private var authentication: Glia.Authentication?
        private var entryWidgetContainerView: UIView?
        private var visitorCodeContainerView: UIView?

        var autoConfigureEnabled: Bool {
            get { appState.autoConfigureEnabled }
            set { appState.autoConfigureEnabled = newValue }
        }

        var sdkFlowMode: SDKFlowMode {
            get { appState.sdkFlowMode }
            set {
                appState.sdkFlowMode = newValue
                appState.saveConfiguration()
            }
        }

        var authenticationBehavior: Glia.Authentication.Behavior {
            get { appState.authenticationBehavior }
            set { appState.authenticationBehavior = newValue }
        }

        init(appState: AppState) {
            self.appState = appState
        }
    }
}

extension ContentView.ViewModel {
    func configureSDK() {
        configurationState = .loading

        guard appState.sdkFlowMode == .completionHandlers else {
            Task { [weak self] in
                guard let self else { return }
                do {
                    try await appState.configure()
                    configurationState = .configured
                } catch {
                    handleConfigurationFailure(error)
                }
            }
            return
        }

        appState.configure { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.configurationState = .configured
                case .failure(let error):
                    self.configurationState = .error(error.localizedDescription)
                    self.showError = AlertData(
                        title: "Configuration Failed",
                        message: error.localizedDescription
                    )
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.configurationState = .idle
                    }
                }
            }
        }
    }

    private func handleConfigurationFailure(_ error: Error) {
        configurationState = .error(error.localizedDescription)
        showError = AlertData(
            title: "Configuration Failed",
            message: error.localizedDescription
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.configurationState = .idle
        }
    }

    func showVisitorInfoTapped() {
        self.showVisitorInfo.toggle()
    }

    func showSensitiveDataTapped() {
        self.showSensitiveData.toggle()
    }

    func startEngagement(_ action: @escaping () throws -> Void) {
        let execute = { [weak self] in
            guard let self = self else { return }
            do {
                try action()
            } catch {
                self.showError = AlertData(
                    title: "Engagement Failed",
                    message: error.localizedDescription
                )
            }
        }

        if autoConfigureEnabled && !appState.isConfigured {
            configurationState = .loading
            guard appState.sdkFlowMode == .completionHandlers else {
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        try await appState.configure()
                        configurationState = .configured
                        execute()
                    } catch {
                        handleConfigurationFailure(error)
                    }
                }
                return
            }

            appState.configure { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.configurationState = .configured
                    execute()

                case .failure(let error):
                    self.configurationState = .error(error.localizedDescription)
                    self.showError = AlertData(
                        title: "Configuration Failed",
                        message: error.localizedDescription
                    )
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.configurationState = .idle
                    }
                }
            }
        } else {
            appState.applyPushNotificationConfig()
            execute()
        }
    }

    func resumeEngagement() {
        do {
            try Glia.sharedInstance.resume()
        } catch {
            showError = AlertData(
                title: "Resume Failed",
                message: error.localizedDescription
            )
        }
    }

    func handleAuthentication() {
        if isAuthenticated {
            guard appState.sdkFlowMode == .completionHandlers else {
                Task { [weak self] in
                    guard let self, let authentication else { return }
                    do {
                        try await authentication.deauthenticate(
                            shouldStopPushNotifications: appState.stopPushOnDeauthenticate
                        )
                        self.authentication = nil
                        isAuthenticated = false
                    } catch {
                        showError = AlertData(
                            title: "Deauthentication Failed",
                            message: error.localizedDescription
                        )
                    }
                }
                return
            }

            authentication?.deauthenticate(
                shouldStopPushNotifications: appState.stopPushOnDeauthenticate
            ) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.authentication = nil
                        self.isAuthenticated = false
                    case .failure(let error):
                        self.showError = AlertData(
                            title: "Deauthentication Failed",
                            message: error.reason
                        )
                    }
                }
            }
        } else {
            let authenticateAction = { [weak self] in
                guard let self = self else { return }
                do {
                    let auth = try Glia.sharedInstance.authentication(with: self.authenticationBehavior)
                    if !auth.isAuthenticated {
                        self.authentication = auth
                        self.showAuthenticationAlert = true
                    }
                } catch {
                    self.showError = AlertData(
                        title: "Authentication Error",
                        message: error.localizedDescription
                    )
                }
            }

            if autoConfigureEnabled && !appState.isConfigured {
                configurationState = .loading
                guard appState.sdkFlowMode == .completionHandlers else {
                    Task { [weak self] in
                        guard let self else { return }
                        do {
                            try await appState.configure()
                            configurationState = .configured
                            authenticateAction()
                        } catch {
                            handleConfigurationFailure(error)
                        }
                    }
                    return
                }

                appState.configure { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        self.configurationState = .configured
                        authenticateAction()
                    case .failure(let error):
                        self.configurationState = .error(error.localizedDescription)
                        self.showError = AlertData(
                            title: "Configuration Failed",
                            message: error.localizedDescription
                        )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.configurationState = .idle
                        }
                    }
                }
            } else {
                appState.applyPushNotificationConfig()
                authenticateAction()
            }
        }
    }

    func authenticateWithJWT() {
        guard let authentication = authentication else { return }

        guard appState.sdkFlowMode == .completionHandlers else {
            Task { [weak self] in
                guard let self else { return }
                do {
                    try await authentication.authenticate(
                        with: jwtToken,
                        accessToken: accessToken.isEmpty ? nil : accessToken
                    )
                    jwtToken = ""
                    accessToken = ""
                    isAuthenticated = true
                } catch {
                    jwtToken = ""
                    accessToken = ""
                    isAuthenticated = false
                    showError = AlertData(
                        title: "Authentication Failed",
                        message: error.localizedDescription
                    )
                }
            }
            return
        }

        authentication.authenticate(
            with: jwtToken,
            accessToken: accessToken.isEmpty ? nil : accessToken
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.jwtToken = ""
                self.accessToken = ""

                switch result {
                case .success:
                    self.isAuthenticated = true
                case .failure(let error):
                    self.isAuthenticated = false
                    self.showError = AlertData(
                        title: "Authentication Failed",
                        message: error.reason
                    )
                }
            }
        }
    }

    func refreshAccessToken() {
        guard let authentication = authentication else { return }

        guard appState.sdkFlowMode == .completionHandlers else {
            Task { [weak self] in
                guard let self else { return }
                do {
                    try await authentication.refresh(
                        with: jwtToken,
                        accessToken: accessToken.isEmpty ? nil : accessToken
                    )
                    jwtToken = ""
                    accessToken = ""
                    showError = AlertData(
                        title: "Success",
                        message: "Access token successfully refreshed"
                    )
                } catch {
                    jwtToken = ""
                    accessToken = ""
                    showError = AlertData(
                        title: "Refresh Failed",
                        message: error.localizedDescription
                    )
                }
                isAuthenticated = authentication.isAuthenticated
            }
            return
        }

        authentication.refresh(
            with: jwtToken,
            accessToken: accessToken.isEmpty ? nil : accessToken
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.jwtToken = ""
                self.accessToken = ""

                switch result {
                case .success:
                    self.showError = AlertData(
                        title: "Success",
                        message: "Access token successfully refreshed"
                    )
                case .failure(let error):
                    self.showError = AlertData(
                        title: "Refresh Failed",
                        message: error.reason
                    )
                }
                self.isAuthenticated = authentication.isAuthenticated
            }
        }
    }

    func showEntryWidgetSheet() {
        guard let entryWidget = appState.entryWidget else {
            showError = AlertData(
                title: "Entry Widget Unavailable",
                message: "Please configure SDK first"
            )
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            showError = AlertData(
                title: "Error",
                message: "Could not find root view controller"
            )
            return
        }

        entryWidget.show(in: rootViewController)
    }

    func showVisitorCodeAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            showError = AlertData(
                title: "Error",
                message: "Could not find root view controller"
            )
            return
        }

        Glia.sharedInstance.callVisualizer.showVisitorCodeViewController(from: rootViewController)
    }

    func setEntryWidgetContainer(_ view: UIView) {
        self.entryWidgetContainerView = view
    }

    func setVisitorCodeContainer(_ view: UIView) {
        self.visitorCodeContainerView = view
    }

    func toggleEntryWidgetEmbed() {
        guard let containerView = entryWidgetContainerView,
              let entryWidget = appState.entryWidget else {
            showError = AlertData(
                title: "Entry Widget Unavailable",
                message: "Please configure SDK first"
            )
            return
        }

        if isEntryWidgetEmbedded {
            containerView.subviews.forEach { $0.removeFromSuperview() }
            isEntryWidgetEmbedded = false
        } else {
            entryWidget.embed(in: containerView)
            isEntryWidgetEmbedded = true
        }
    }

    func toggleVisitorCodeEmbed() {
        guard let containerView = visitorCodeContainerView else {
            showError = AlertData(
                title: "Container Unavailable",
                message: "Visitor code container not ready"
            )
            return
        }

        if isVisitorCodeEmbedded {
            containerView.subviews.forEach { $0.removeFromSuperview() }
            isVisitorCodeEmbedded = false
        } else {
            Glia.sharedInstance.callVisualizer.embedVisitorCodeView(
                into: containerView
            ) {
                containerView.subviews.forEach { $0.removeFromSuperview() }
            }
            isVisitorCodeEmbedded = true
        }
    }

    func clearSession() {
        guard appState.sdkFlowMode == .completionHandlers else {
            Task { [weak self] in
                guard let self else { return }
                do {
                    try await appState.clearSession()
                } catch {
                    showError = AlertData(
                        title: "Clear Session Failed",
                        message: error.localizedDescription
                    )
                }
            }
            return
        }

        appState.clearSession { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case .failure(let error) = result {
                    self.showError = AlertData(
                        title: "Clear Session Failed",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    func endEngagement() {
        guard appState.sdkFlowMode == .completionHandlers else {
            Task { [weak self] in
                guard let self else { return }
                do {
                    try await appState.endEngagement()
                } catch {
                    showError = AlertData(
                        title: "End Engagement Failed",
                        message: error.localizedDescription
                    )
                }
            }
            return
        }

        appState.endEngagement { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case .failure(let error) = result {
                    self.showError = AlertData(
                        title: "End Engagement Failed",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
}

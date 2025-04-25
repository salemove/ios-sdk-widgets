import Foundation
import GliaWidgets

extension ViewController {
    @IBAction private func configureSDKTapped() {
        setupPushNotificationConfig()
        showRemoteConfigAlert { [weak self] fileName in
            self?.configureSDK(uiConfigName: fileName) { result in
                guard case let .failure(error) = result else { return }
                self?.showErrorAlert(using: error)
            }
        }
    }
    
    func prepareGlia(completion: @escaping () -> Void) {
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

        setupPushNotificationConfig()

        if autoConfigureSdkToggle.isOn {
            configureSDK(uiConfigName: nil) { [weak self] result in
                switch result {
                case .success:
                    completion()
                case let .failure(error):
                    self?.showErrorAlert(using: error)
                    completion()
                }
            }
        } else {
            completion()
        }
    }

    func setupPushNotificationConfig() {
        #if DEBUG
        let pushNotifications = Configuration.PushNotifications.sandbox
        #else
        let pushNotifications = Configuration.PushNotifications.production
        #endif
        configuration.pushNotifications = pushNotifications

        let pushNotificationsTypes: [PushNotificationsType] = [.start, .message, .end]
        Glia.sharedInstance.pushNotifications.subscribeTo(pushNotificationsTypes)
    }

    func configureSDK(
        uiConfigName: String?,
        completion: ((Result<Void, Error>) -> Void)? = nil
    ) {
        let originalTitle = configureButton.title(for: .normal)
        let originalIdentifier = configureButton.accessibilityIdentifier
        configureButton.setTitle("Configuring ...", for: .normal)
        configureButton.accessibilityIdentifier = "main_configure_sdk_button_loading"

        let completionBlock = { [weak self] printable in
            self?.configureButton.setTitle(originalTitle, for: .normal)
            self?.configureButton.accessibilityIdentifier = originalIdentifier
            debugPrint(printable)
        }

        let uiConfig = retrieveRemoteConfiguration(uiConfigName)

        do {
            try Glia.sharedInstance.configure(
                with: configuration,
                theme: theme,
                uiConfig: uiConfig,
                features: features
            ) { [weak self] result in
                guard let self else {
                    return
                }
                switch result {
                case .success:
                    self.catchingError {
                        self.entryWidget = try Glia.sharedInstance.getEntryWidget(queueIds: [self.queueId])
                        self.engagementLauncher = try Glia.sharedInstance.getEngagementLauncher(queueIds: [self.queueId])
                    }
                    completionBlock("SDK has been configured")
                    completion?(.success(()))

                case let .failure(error):
                    completionBlock("Error configuring the SDK")
                    completion?(.failure(error))
                }
            }
        } catch {
            completionBlock(error)
            completion?(.failure(error))
        }
    }

}

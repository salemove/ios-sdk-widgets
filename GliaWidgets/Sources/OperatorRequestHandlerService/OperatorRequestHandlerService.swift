import UIKit

final class OperatorRequestHandlerService {
    private let environment: Environment
    private let viewFactory: ViewFactory
    private var alertViewController: AlertViewController?
    private var alertWindow: UIWindow?

    init(
        environment: Environment,
        viewFactory: ViewFactory
    ) {
        self.environment = environment
        self.viewFactory = viewFactory
    }
}

// MARK: - Public Methods
extension OperatorRequestHandlerService {
    func offerMediaUpgrade(
        from operators: String,
        offer: CoreSdkClient.MediaUpgradeOffer,
        accepted: (() -> Void)? = nil,
        declined: (() -> Void)? = nil,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
    ) {
        switch offer.type {
        case .audio:
            let configuration = alertConfiguration().audioUpgrade
            makeAudioUpgradeAlert(
                with: configuration.withOperatorName(operators),
                offer: offer,
                accepted: accepted,
                declined: declined,
                answer: answer
            )
        case .video:
            switch offer.direction {
            case .oneWay:
                let configuration = alertConfiguration().oneWayVideoUpgrade
                makeOneWayVideoUpgradeAlert(
                    with: configuration.withOperatorName(operators),
                    offer: offer,
                    accepted: accepted,
                    declined: declined,
                    answer: answer
                )
            case .twoWay:
                let configuration = alertConfiguration().twoWayVideoUpgrade
                makeTwoWayVideoUpgradeAlert(
                    with: configuration.withOperatorName(operators),
                    offer: offer,
                    accepted: accepted,
                    declined: declined,
                    answer: answer
                )
            default:
                return
            }
        default:
            break
        }
    }

    func offerScreenShare(
        from operators: String,
        accepted: (() -> Void)? = nil,
        declined: (() -> Void)? = nil,
        answer: @escaping CoreSdkClient.AnswerBlock
    ) {
        environment.log.prefixed(Self.self).info("Show Start Screen Sharing Dialog")
        let configuration = alertConfiguration().screenShareOffer

        let acceptedOffer: () -> Void = { [weak self] in
            self?.dismiss()
            self?.environment.log.prefixed(Self.self).info("Screen sharing accepted by visitor")
            answer(true)
            accepted?()
        }

        let declinedOffer: () -> Void = { [weak self] in
            self?.dismiss()
            self?.environment.log.prefixed(Self.self).info("Screen sharing declined by visitor")
            answer(false)
            declined?()
        }

        let alertKind: AlertViewController.Kind = .screenShareOffer(
            configuration.withOperatorName(operators),
            accepted: acceptedOffer,
            declined: declinedOffer
        )

        let alert = makeAlert(kind: alertKind)
        present(alert)
    }

    func overrideTheme(_ theme: Theme) {
        viewFactory.overrideTheme(with: theme)
    }
}

// MARK: - Private Methods
private extension OperatorRequestHandlerService {
    func makeOneWayVideoUpgradeAlert(
        with config: SingleMediaUpgradeAlertConfiguration,
        offer: CoreSdkClient.MediaUpgradeOffer,
        accepted: (() -> Void)? = nil,
        declined: (() -> Void)? = nil,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
    ) {
        environment.log.prefixed(Self.self).info("1 way video upgrade requested")
        environment.log.prefixed(Self.self).info("Show Upgrade 1WayVideo Dialog")

        let acceptedOffer: () -> Void = { [weak self] in
            self?.dismiss()
            self?.environment.log.prefixed(Self.self).info("Upgrade offer accepted by visitor")
            accepted?()
            answer(true, nil)
        }

        let declinedOffer: () -> Void = { [weak self] in
            self?.dismiss()
            self?.environment.log.prefixed(Self.self).info("Upgrade offer declined by visitor")
            declined?()
            answer(false, nil)
        }

        let alertKind: AlertViewController.Kind = .singleMediaUpgrade(
            config,
            accepted: acceptedOffer,
            declined: declinedOffer
        )

        let alert = makeAlert(kind: alertKind)
        present(alert)
    }

    func makeTwoWayVideoUpgradeAlert(
        with config: SingleMediaUpgradeAlertConfiguration,
        offer: CoreSdkClient.MediaUpgradeOffer,
        accepted: (() -> Void)? = nil,
        declined: (() -> Void)? = nil,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
    ) {
        environment.log.prefixed(Self.self).info("2 way video upgrade requested")
        environment.log.prefixed(Self.self).info("Show Upgrade 2WayVideo Dialog")

        let acceptedOffer: () -> Void = { [weak self] in
            self?.dismiss()
            self?.environment.log.prefixed(Self.self).info("Upgrade offer accepted by visitor")
            accepted?()
            answer(true, nil)
        }

        let declinedOffer: () -> Void = { [weak self] in
            self?.dismiss()
            self?.environment.log.prefixed(Self.self).info("Upgrade offer declined by visitor")
            declined?()
            answer(false, nil)
        }

        let alertKind: AlertViewController.Kind = .singleMediaUpgrade(
            config,
            accepted: acceptedOffer,
            declined: declinedOffer
        )

        let alert = makeAlert(kind: alertKind)
        present(alert)
    }

    func makeAudioUpgradeAlert(
        with config: SingleMediaUpgradeAlertConfiguration,
        offer: CoreSdkClient.MediaUpgradeOffer,
        accepted: (() -> Void)? = nil,
        declined: (() -> Void)? = nil,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
    ) {
        environment.log.prefixed(Self.self).info("Audio upgrade requested")
        environment.log.prefixed(Self.self).info("Show Upgrade Audio Dialog")

        let acceptedOffer: () -> Void = { [weak self] in
            self?.dismiss()
            self?.environment.log.prefixed(Self.self).info("Upgrade offer accepted by visitor")
            accepted?()
            answer(true, nil)
        }

        let declinedOffer: () -> Void = { [weak self] in
            self?.dismiss()
            self?.environment.log.prefixed(Self.self).info("Upgrade offer declined by visitor")
            declined?()
            answer(false, nil)
        }

        let alertKind: AlertViewController.Kind = .singleMediaUpgrade(
            config,
            accepted: acceptedOffer,
            declined: declinedOffer
        )

        let alert = makeAlert(kind: alertKind)
        present(alert)
    }

    func dismiss() {
        alertViewController?.dismiss(animated: true)
        alertViewController = nil
        alertWindow?.isHidden = true
        alertWindow = nil
    }

    func present(_ alert: AlertViewController) {
        alertViewController = alert
        replacePresentedOfferIfPossible(with: alert)
    }

    func makeAlert(kind: AlertViewController.Kind) -> AlertViewController {
        .init(kind: kind, viewFactory: viewFactory)
    }

    func replacePresentedOfferIfPossible(with offer: Replaceable) {
        guard let alertViewController else {
            presentAlertViewController(offer)
            return
        }

        guard alertViewController.isReplaceable(with: offer) else { return }
        alertViewController.dismiss(animated: true) { [weak self] in
            self?.presentAlertViewController(offer)
        }
    }

    func alertConfiguration() -> AlertConfiguration {
        return viewFactory.theme.alertConfiguration
    }
}

// MARK: - Top ViewController
private extension OperatorRequestHandlerService {
    func createAlertWindow() {
        if let windowScene = windowScene() {
            alertWindow = UIWindow(windowScene: windowScene)
        } else {
            alertWindow = UIWindow(frame: UIScreen.main.bounds)
        }

        alertWindow?.windowLevel = UIWindow.Level.alert + 1
        alertWindow?.rootViewController = UIViewController()
    }

    func windowScene() -> UIWindowScene? {
        environment.uiApplication.connectionScenes()
            .compactMap { $0 as? UIWindowScene }
            .first
    }

    func presentAlertViewController(_ alertViewController: Replaceable) {
        createAlertWindow()
        guard let alertWindow = alertWindow else { return }
        alertWindow.isHidden = false
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertViewController, animated: true, completion: nil)
    }
}

// MARK: - Environment
extension OperatorRequestHandlerService {
    struct Environment {
        let uiApplication: UIKitBased.UIApplication
        let log: CoreSdkClient.Logger
    }
}

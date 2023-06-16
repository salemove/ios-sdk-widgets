import UIKit

class AlertViewController: UIViewController {
    enum Kind {
        case message(
            MessageAlertConfiguration,
            accessibilityIdentifier: String?,
            dismissed: (() -> Void)?
        )
        case confirmation(
            ConfirmationAlertConfiguration,
            accessibilityIdentifier: String,
            confirmed: () -> Void
        )
        case singleAction(
            SingleActionAlertConfiguration,
            accessibilityIdentifier: String,
            actionTapped: () -> Void
        )
        case singleMediaUpgrade(
            SingleMediaUpgradeAlertConfiguration,
            accepted: () -> Void,
            declined: () -> Void
        )
        case screenShareOffer(
            ScreenShareOfferAlertConfiguration,
            accepted: () -> Void,
            declined: () -> Void
        )
    }

    let viewFactory: ViewFactory

    private let kind: Kind
    private var alertView: AlertView?
    private let alertInsets = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)

    init(
        kind: Kind,
        viewFactory: ViewFactory
    ) {
        self.kind = kind
        self.viewFactory = viewFactory
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        super.loadView()
        let view = UIView()

        if case let Kind.message(conf, _, _) = kind, !conf.shouldShowCloseButton {
            view.backgroundColor = UIColor.clear
            view.isUserInteractionEnabled = false
        } else {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            view.isUserInteractionEnabled = true
        }

        self.view = view
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showAlertView(animated: animated)
    }

    private func showAlertView(animated: Bool) {
        guard alertView == nil else { return }

        let alertView = makeAlertView()
        self.alertView = alertView

        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        alertView.layoutIn(
            view.safeAreaLayoutGuide,
            edges: [.horizontal, .bottom],
            insets: alertInsets
         ).activate()

        alertView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        alertView.transform = .identity
                       }, completion: nil)
    }

    private func hideAlertView(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.4 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.alertView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                       }, completion: { _ in
                        self.alertView = nil
                       })
    }

    private func makeAlertView() -> AlertView {
        switch kind {
        case .message(let conf, let accessibilityIdentifier, let dismissed):
            return makeMessageAlertView(
                with: conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: dismissed
            )
        case .confirmation(let conf, let accessibilityIdentifier, let confirmed):
            return makeConfirmationAlertView(
                with: conf,
                accessibilityIdentifier: accessibilityIdentifier,
                confirmed: confirmed
            )
        case .singleAction(let conf, let accessibilityIdentifier, let actionTapped):
            return makeSingleActionAlertView(
                with: conf,
                accessibilityIdentifier: accessibilityIdentifier,
                actionTapped: actionTapped
            )
        case .singleMediaUpgrade(let conf, accepted: let accepted, declined: let declined):
            return makeMediaUpgradeAlertView(
                with: conf,
                accepted: accepted,
                declined: declined
            )
        case .screenShareOffer(let conf, accepted: let accepted, declined: let declined):
            return makeScreenShareOfferAlertView(
                with: conf,
                accepted: accepted,
                declined: declined
            )
        }
    }

    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        hideAlertView(animated: animated)
        super.dismiss(animated: animated, completion: completion)
    }
}

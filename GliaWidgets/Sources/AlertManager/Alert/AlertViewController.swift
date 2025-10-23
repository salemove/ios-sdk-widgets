import UIKit

class AlertViewController: UIViewController, Replaceable {
    let viewFactory: ViewFactory

    /// Indicating presentation priority of an alert.
    /// Based on comparing values we can decide whether an alert can be replaced with another alert.
    var presentationPriority: PresentationPriority {
        type.presentationPriority
    }

    var onDismissed: (() -> Void)?

    private let type: AlertType
    private var alertView: AlertView?
    private let alertInsets = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)

    init(
        type: AlertType,
        viewFactory: ViewFactory
    ) {
        self.type = type
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

        if case let AlertType.message(conf, _, _, _) = type, !conf.shouldShowCloseButton {
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

        guard let alertView = makeAlertView() else { return }
        self.alertView = alertView

        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            alertView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: alertInsets.left),
            alertView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -alertInsets.right),
            alertView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            alertView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            alertView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -alertInsets.bottom)
        ]
        NSLayoutConstraint.activate(constraints)

        alertView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(
            withDuration: animated ? 0.4 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: {
                alertView.transform = .identity
            },
            completion: nil
        )
    }

    private func hideAlertView(animated: Bool) {
        UIView.animate(
            withDuration: animated ? 0.4 : 0.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.7,
            options: .curveEaseInOut,
            animations: {
                self.alertView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: { _ in
                self.alertView = nil
                self.onDismissed?()
            }
        )
    }

    // swiftlint:disable:next function_body_length
    private func makeAlertView() -> AlertView? {
        switch type {
        case let .message(conf, accessibilityIdentifier, dismissed, _):
            return makeMessageAlertView(
                with: conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: dismissed
            )
        case let .confirmation(conf, accessibilityIdentifier, confirmed, dismissed, _):
            return makeConfirmationAlertView(
                with: conf,
                accessibilityIdentifier: accessibilityIdentifier,
                confirmed: confirmed,
                dismissed: dismissed
            )
        case let .leaveConversation(conf, accessibilityIdentifier, confirmed, declined, _):
            return makeLeaveConversationAlertView(
                with: conf,
                accessibilityIdentifier: accessibilityIdentifier,
                confirmed: confirmed,
                declined: declined
            )
        case let .singleAction(conf, accessibilityIdentifier, actionTapped, _):
            return makeSingleActionAlertView(
                with: conf,
                accessibilityIdentifier: accessibilityIdentifier,
                actionTapped: actionTapped
            )
        case let .singleMediaUpgrade(conf, accepted, declined, _):
            return makeMediaUpgradeAlertView(
                with: conf,
                accepted: accepted,
                declined: declined
            )
        case let .liveObservationConfirmation(conf, link1, link2, accepted, declined, _):
            return makeLiveObservationAlertView(
                with: conf,
                link1: link1,
                link2: link2,
                accepted: accepted,
                declined: declined
            )
        case .systemAlert:
            /// This should never be called because system alerts are
            /// displayed as UIAlertController and not AlertView. We only need
            /// this case to differenciate between alert types.
            return nil
        case let .view(conf, accessibilityIdentifier, dismissed, _):
            return makeMessageAlertView(
                with: conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: dismissed
            )
        case let .criticalError(conf, accessibilityIdentifier, dismissed, _):
            return makeMessageAlertView(
                with: conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: dismissed
            )
        case let .requestPushNotificationsPermissions(conf, accepted, declined, _):
            return makeRequestPNPermissionsAlertView(
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

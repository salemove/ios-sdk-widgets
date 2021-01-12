import UIKit
import SalemoveSDK

class AlertViewController: ViewController {
    enum Kind {
        case message(AlertMessageStrings,
                     dismissed: (() -> Void)?)
        case confirmation(AlertConfirmationStrings,
                          confirmed: () -> Void)
        case mediaUpgrade(AlertTitleStrings,
                          mediaTypes: [MediaType],
                          accepted: (Int) -> Void,
                          declined: () -> Void)
    }

    private let viewFactory: ViewFactory
    private let kind: Kind
    private var alertView: AlertView?
    private let kAlertInsets = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)

    init(kind: Kind, viewFactory: ViewFactory) {
        self.kind = kind
        self.viewFactory = viewFactory
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.view = view
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showAlertView(animated: animated)
    }

    private func showAlertView(animated: Bool) {
        guard alertView == nil else { return }

        let alertView = makeAlertView()
        self.alertView = alertView

        view.addSubview(alertView)
        alertView.autoPinEdgesToSuperviewSafeArea(with: kAlertInsets,
                                                  excludingEdge: .top)

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
        let alertView = viewFactory.makeAlertView()

        switch kind {
        case .message(let strings, let dismissed):
            alertView.title = strings.title
            alertView.message = strings.message
            alertView.showsCloseButton = true
            alertView.closeTapped = { [weak self] in
                self?.dismiss(animated: true) {
                    dismissed?()
                }
            }
        case .confirmation(let strings, let confirmed):
            alertView.title = strings.title
            alertView.message = strings.message
            alertView.showsPoweredBy = true
            alertView.actionsAxis = .horizontal

            let negativeButton = ActionButton(with: viewFactory.theme.alert.negativeAction)
            negativeButton.title = strings.negativeTitle
            negativeButton.tap = { [weak self] in
                self?.dismiss(animated: true)
            }
            let positiveButton = ActionButton(with: viewFactory.theme.alert.positiveAction)
            positiveButton.title = strings.positiveTitle
            positiveButton.tap = { [weak self] in
                self?.dismiss(animated: true) {
                    confirmed()
                }
            }
            alertView.addActionView(negativeButton)
            alertView.addActionView(positiveButton)
        case .mediaUpgrade(let strings, mediaTypes: let mediaTypes, accepted: let accepted, declined: let declined):
            alertView.title = strings.title
            alertView.showsPoweredBy = true
            alertView.showsCloseButton = true
            alertView.actionsAxis = .vertical

            mediaTypes.enumerated().forEach({
                if let actionView = self.actionView(for: $0.element) {
                    let index = $0.offset
                    actionView.tap = { accepted(index) }
                    alertView.addActionView(actionView)
                }
            })

            alertView.closeTapped = { [weak self] in
                self?.dismiss(animated: true) {
                    declined()
                }
            }
        }

        return alertView
    }

    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        hideAlertView(animated: animated)
        super.dismiss(animated: animated, completion: completion)
    }
}

private extension AlertViewController {
    func actionView(for mediaType: MediaType) -> MediaUpgradeActionView? {
        switch mediaType {
        case .audio:
            return MediaUpgradeActionView(with: viewFactory.theme.alert.audioUpgradeAction)
        case .phone:
            return MediaUpgradeActionView(with: viewFactory.theme.alert.phoneUpgradeAction)
        default:
            return nil
        }
    }
}

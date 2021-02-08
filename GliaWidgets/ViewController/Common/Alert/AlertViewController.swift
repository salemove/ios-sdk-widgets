import UIKit
import SalemoveSDK

class AlertViewController: ViewController {
    enum Kind {
        case message(MessageAlertConfiguration,
                     dismissed: (() -> Void)?)
        case confirmation(ConfirmationAlertConfiguration,
                          confirmed: () -> Void)
        case multipleMediaUpgrade(MultipleMediaUpgradeAlertConfiguration,
                                  mediaTypes: [MediaType],
                                  accepted: (Int) -> Void,
                                  declined: () -> Void)
        case singleMediaUpgrade(SingleMediaUpgradeAlertConfiguration,
                                accepted: () -> Void,
                                declined: () -> Void)
    }

    let viewFactory: ViewFactory

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
        switch kind {
        case .message(let conf, let dismissed):
            return makeMessageAlertView(
                with: conf,
                dismissed: dismissed
            )
        case .confirmation(let conf, let confirmed):
            return makeConfirmationAlertView(
                with: conf,
                confirmed: confirmed
            )
        case .multipleMediaUpgrade(let conf, mediaTypes: let mediaTypes, accepted: let accepted, declined: let declined):
            return makeMediaUpgradeAlertView(
                with: conf,
                mediaTypes: mediaTypes,
                accepted: accepted,
                declined: declined
            )
        case .singleMediaUpgrade(let conf, accepted: let accepted, declined: let declined):
            return makeMediaUpgradeAlertView(
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

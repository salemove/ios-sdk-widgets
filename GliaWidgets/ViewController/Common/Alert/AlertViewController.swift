import UIKit

class AlertViewController: ViewController {
    enum Kind {
        case message(AlertMessageTexts)
        case confirmation(AlertConfirmationTexts,
                          confirmed: () -> Void)
    }

    private let viewFactory: ViewFactory
    private let kind: Kind
    private var alertView: AlertView?
    private let kAlertInsets = UIEdgeInsets(top: 0, left: 20, bottom: 30, right: 20)

    init(kind: Kind, viewFactory: ViewFactory) {
        self.kind = kind
        self.viewFactory = viewFactory
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
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
        alertView.closeTapped = { self.dismiss(animated: animated) }
        self.alertView = alertView

        view.addSubview(alertView)
        alertView.autoPinEdgesToSuperviewSafeArea(with: kAlertInsets,
                                                  excludingEdge: .top)

        alertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
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
                        self.alertView?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                       }, completion: { _ in
                        self.alertView = nil
                       })
    }

    private func makeAlertView() -> AlertView {
        let alertView = viewFactory.makeAlertView()

        switch kind {
        case .message(let texts):
            alertView.title = texts.title
            alertView.message = texts.message
            alertView.showsCloseButton = true
        case .confirmation(let texts, let confirmed):
            alertView.title = texts.title
            alertView.message = texts.message
            alertView.showsCloseButton = false
            alertView.actionsAxis = .horizontal

            let negativeButton = AlertActionButton(with: viewFactory.theme.alert.negativeAction)
            negativeButton.title = texts.negativeTitle
            negativeButton.tap = {
                self.dismiss(animated: true)
            }
            let positiveButton = AlertActionButton(with: viewFactory.theme.alert.positiveAction)
            positiveButton.title = texts.positiveTitle
            positiveButton.tap = {
                self.dismiss(animated: true) {
                    confirmed()
                }
            }
            alertView.addActionView(negativeButton)
            alertView.addActionView(positiveButton)
        }

        return alertView
    }

    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        hideAlertView(animated: animated)
        super.dismiss(animated: animated, completion: completion)
    }
}

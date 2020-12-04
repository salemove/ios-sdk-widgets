import UIKit

class AlertViewController: ViewController {
    enum Kind {
        case message(AlertMessageContent)
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

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAlertView(animated: animated)
    }

    private func showAlertView(animated: Bool) {
        guard alertView == nil else { return }

        let alertView = makeAlertView()
        self.alertView = alertView

        view.addSubview(alertView)
        alertView.autoPinEdgesToSuperviewEdges(with: kAlertInsets,
                                               excludingEdge: .top)
    }

    private func hideAlertView(animated: Bool) {

    }

    private func makeAlertView() -> AlertView {
        let alertView = viewFactory.makeAlertView()

        switch kind {
        case .message(let content):
            alertView.title = content.title
            alertView.message = content.message
            alertView.showsCloseButton = true
        }

        return alertView
    }
}

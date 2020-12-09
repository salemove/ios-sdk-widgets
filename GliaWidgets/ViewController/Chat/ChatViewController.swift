import UIKit

class ChatViewController: ViewController, AlertPresenter {
    internal let viewFactory: ViewFactory
    private let viewModel: ChatViewModel
    private let presentationKind: PresentationKind

    init(viewModel: ChatViewModel,
         viewFactory: ViewFactory,
         presentationKind: PresentationKind) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        self.presentationKind = presentationKind
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        let view = viewFactory.makeChatView()
        self.view = view
        bind(viewModel: viewModel, to: view)
        addDemoAlertButtons()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    private func bind(viewModel: ChatViewModel, to view: ChatView) {
        view.header.leftItem = {
            switch presentationKind {
            case .push:
                return Button(kind: .back, tap: { viewModel.event(.backTapped) })
            case .present:
                return Button(kind: .close, tap: { viewModel.event(.closeTapped) })
            }
        }()

        viewModel.action = { action in
            switch action {
            case .showAlert(let texts):
                self.presentAlert(with: texts)
            case .confirmExitQueue(let texts):
                self.presentConfirmation(with: texts) {
                    print("CONFIRMED")
                }
            }
        }
    }
}

extension ChatViewController {
    private func addDemoAlertButtons() {
        let alertButton = UIButton(type: .system)
        alertButton.setTitle("Alert", for: .normal)
        alertButton.addTarget(self, action: #selector(alertTapped), for: .touchUpInside)
        view.addSubview(alertButton)
        alertButton.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        alertButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)

        let confirmationButton = UIButton(type: .system)
        confirmationButton.setTitle("Confirm", for: .normal)
        confirmationButton.addTarget(self, action: #selector(confirmationTapped), for: .touchUpInside)
        view.addSubview(confirmationButton)
        confirmationButton.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        confirmationButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
    }

    @objc private func alertTapped() {
        viewModel.event(.alertTapped)
    }

    @objc private func confirmationTapped() {
        viewModel.event(.confirmTapped)
    }
}

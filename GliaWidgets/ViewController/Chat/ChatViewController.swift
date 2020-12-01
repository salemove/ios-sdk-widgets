import UIKit

class ChatViewController: ViewController {
    private let viewModel: ChatViewModel
    private let viewFactory: ViewFactory
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
        let view = viewFactory.makeChatView()
        self.view = view
        bind(viewModel: viewModel, to: view)
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
    }
}

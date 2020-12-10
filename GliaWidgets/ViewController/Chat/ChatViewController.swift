import UIKit

class ChatViewController: ViewController, AlertPresenter {
    internal let viewFactory: ViewFactory
    private let viewModel: ChatViewModel

    init(viewModel: ChatViewModel,
         viewFactory: ViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.event(.viewDidLoad)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    private func bind(viewModel: ChatViewModel, to view: ChatView) {
        view.header.leftItem = Button(kind: .back, tap: { viewModel.event(.backTapped) })
        view.header.rightItem = Button(kind: .close, tap: { viewModel.event(.closeTapped) })

        viewModel.action = { action in
            switch action {
            case .showAlert(let texts):
                self.presentAlert(with: texts)
            case .confirmExitQueue(let texts):
                self.presentConfirmation(with: texts) {
                    viewModel.event(.confirmedExitQueue)
                }
            }
        }
    }
}

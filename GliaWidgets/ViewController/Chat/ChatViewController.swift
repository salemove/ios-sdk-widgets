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
        view.numberOfRows = { return viewModel.numberOfItems }
        view.itemForRow = { return viewModel.item(for: $0) }

        viewModel.action = { action in
            switch action {
            case .queueWaiting:
                view.queueView.setState(.waiting, animated: true)
            case .queueConnecting(name: let name):
                view.queueView.setState(.connecting(name: name), animated: true)
            case .queueConnected(name: let name):
                view.queueView.setState(.connected(name: name), animated: true)
            case .appendRows(let count):
                view.appendRows(count, animated: true)
            case .refreshChatItems:
                view.refreshItems()
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

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

    override var preferredStatusBarStyle: UIStatusBarStyle { return viewFactory.theme.chat.header.preferredStatusBarStyle }

    private func bind(viewModel: ChatViewModel, to view: ChatView) {
        let leftItem = Button(kind: .back, tap: { viewModel.event(.backTapped) })
        let rightItem = Button(kind: .close, tap: { viewModel.event(.closeTapped) })

        view.header.setLeftItem(leftItem, animated: false)
        view.header.setRightItem(rightItem, animated: false)
        view.numberOfSections = { return viewModel.numberOfSections }
        view.numberOfRows = { return viewModel.numberOfItems(in: $0) }
        view.itemForRow = { return viewModel.item(for: $0, in: $1) }
        view.messageEntryView.textChanged = { viewModel.event(.messageTextChanged($0)) }
        view.messageEntryView.sendTapped = { viewModel.event(.sendTapped(message: $0)) }

        viewModel.action = { action in
            switch action {
            case .queueWaiting:
                view.setQueueState(.waiting, animated: false)
            case .queueConnecting:
                view.setQueueState(.connecting, animated: true)
            case .queueConnected(name: let name, imageUrl: let imageUrl):
                view.setQueueState(.connected(name: name, imageUrl: imageUrl), animated: true)
            case .showEndButton:
                let rightItem = ActionButton(with: self.viewFactory.theme.chat.endButton)
                rightItem.tap = { viewModel.event(.closeTapped) }
                view.header.setRightItem(rightItem, animated: true)
            case .setMessageEntryEnabled(let enabled):
                view.messageEntryView.isEnabled = enabled
            case .appendRows(let count, let section, let animated):
                view.appendRows(count, to: section, animated: animated)
            case .refreshRow(let row, in: let section, animated: let animated):
                view.refreshRow(row, in: section, animated: animated)
            case .refreshSection(let section):
                view.refreshSection(section)
            case .refreshAll:
                view.refreshAll()
            case .scrollToBottom(animated: let animated):
                view.scrollToBottom(animated: animated)
            case .updateItemsUserImage(animated: let animated):
                view.updateItemsUserImage(animated: animated)
            case .confirm(let strings, let confirmed):
                self.presentConfirmation(with: strings) { confirmed?() }
            case .showAlert(let strings, let dismissed):
                self.presentAlert(with: strings) { dismissed?() }
            }
        }
    }
}

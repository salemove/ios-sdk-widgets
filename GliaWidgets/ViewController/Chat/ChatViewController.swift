import UIKit

import MobileCoreServices

class ChatViewController: EngagementViewController, MediaUpgradePresenter {
    private let viewModel: ChatViewModel
    private var lastVisibleRowIndexPath: IndexPath?

    init(viewModel: ChatViewModel,
         viewFactory: ViewFactory) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, viewFactory: viewFactory)
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

    override var preferredStatusBarStyle: UIStatusBarStyle { return viewFactory.theme.chat.preferredStatusBarStyle }

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard let view = view as? ChatView else { return }
        lastVisibleRowIndexPath = view.tableView.indexPathsForVisibleRows?.last
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        guard let view = view as? ChatView else { return }
        guard let indexPath = lastVisibleRowIndexPath else { return }
        view.tableView.reloadData()
        view.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    private func bind(viewModel: ChatViewModel, to view: ChatView) {
        showBackButton(with: viewFactory.theme.chat.backButton, in: view.header)
        showCloseButton(with: viewFactory.theme.chat.closeButton, in: view.header)

        view.numberOfSections = { return viewModel.numberOfSections }
        view.numberOfRows = { return viewModel.numberOfItems(in: $0) }
        view.itemForRow = { return viewModel.item(for: $0, in: $1) }
        view.messageEntryView.textChanged = { viewModel.event(.messageTextChanged($0)) }
        view.messageEntryView.sendTapped = { viewModel.event(.sendTapped(message: $0)) }
        view.callBubbleTapped = { viewModel.event(.callBubbleTapped) }

        view.messageEntryView.pickMediaTapped = { self.picker() }

        viewModel.action = { action in
            switch action {
            case .queue:
                view.setConnectState(.queue, animated: false)
            case .connected(name: let name, imageUrl: let imageUrl):
                view.setConnectState(.connected(name: name, imageUrl: imageUrl), animated: true)
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
            case .offerMediaUpgrade(let conf, accepted: let accepted, declined: let declined):
                self.offerMediaUpgrade(with: conf, accepted: accepted, declined: declined)
            case .showCallBubble(let imageUrl):
                view.showCallBubble(with: imageUrl, animated: true)
            }
        }
    }

    private func picker() {
        guard let view = view as? ChatView else { return }

        let item1 = ListItemStyle(title: "Photo",
                                  titleFont: .systemFont(ofSize: 15),
                                  titleColor: .black,
                                  icon: Asset.callChat.image,
                                  iconColor: .black)
        let item2 = ListItemStyle(title: "Take photo",
                                  titleFont: .systemFont(ofSize: 15),
                                  titleColor: .black,
                                  icon: Asset.chatSend.image,
                                  iconColor: .black)

        let list = ItemListView(with: ItemListStyle(separatorColor: .lightGray, backgroundColor: .white))
        list.items = [item1, item2]

        let controller = PopoverViewController(with: list,
                                               presentFrom: view.messageEntryView.pickMediaButton,
                                               arrowDirection: [.down])
        present(controller, animated: true, completion: nil)
    }
}

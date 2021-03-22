import UIKit

import MobileCoreServices

class ChatViewController: EngagementViewController, MediaUpgradePresenter, PopoverPresenter, ScreenShareOfferPresenter {
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
        view.messageEntryView.sendTapped = { viewModel.event(.sendTapped) }
        view.messageEntryView.pickMediaTapped = { viewModel.event(.pickMediaTapped) }
        view.messageEntryView.uploadListView.removeTapped = { viewModel.event(.removeUploadTapped($0)) }
        view.fileTapped = { viewModel.event(.fileTapped($0)) }
        view.downloadTapped = { viewModel.event(.downloadTapped($0)) }
        view.callBubbleTapped = { viewModel.event(.callBubbleTapped) }

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
            case .showEndScreenShareButton:
                let endEngagementButton = ActionButton(with: self.viewFactory.theme.chat.endButton)
                endEngagementButton.tap = { viewModel.event(.closeTapped) }
                let endScreenShareButton = HeaderButton(with: self.viewFactory.theme.chat.endScreenShareButton)
                endScreenShareButton.tap = { viewModel.event(.endScreenSharingTapped) }
                view.header.setRightItems([endScreenShareButton, endEngagementButton], animated: true)
            case .setMessageEntryEnabled(let enabled):
                view.messageEntryView.isEnabled = enabled
            case .setMessageText(let text):
                view.messageEntryView.messageText = text
            case .sendButtonHidden(let hidden):
                view.messageEntryView.showsSendButton = !hidden
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
            case .addUpload(let upload):
                view.messageEntryView.uploadListView.addUploadView(with: upload)
            case .removeUpload(let upload):
                view.messageEntryView.uploadListView.removeUploadView(with: upload)
            case .removeAllUploads:
                view.messageEntryView.uploadListView.removeAllUploadViews()
            case .presentMediaPicker(itemSelected: let itemSelected):
                self.presentMediaPicker(from: view.messageEntryView.pickMediaButton,
                                        itemSelected: itemSelected)
            case .offerMediaUpgrade(let conf, accepted: let accepted, declined: let declined):
                self.offerMediaUpgrade(with: conf, accepted: accepted, declined: declined)
            case .showCallBubble(let imageUrl):
                view.showCallBubble(with: imageUrl, animated: true)
            }
        }
    }

    private func presentMediaPicker(from sourceView: UIView,
                                    itemSelected: @escaping (ListItemKind) -> Void) {
        presentPopover(with: viewFactory.theme.chat.pickMedia,
                       from: sourceView,
                       arrowDirections: [.down],
                       itemSelected: {
                        self.dismiss(animated: true, completion: nil)
                        itemSelected($0)
                       })
    }
}

import MobileCoreServices
import UIKit

class ChatViewController: EngagementViewController, MediaUpgradePresenter,
    PopoverPresenter, ScreenShareOfferPresenter {
    private let viewModel: ChatViewModel
    private var lastVisibleRowIndexPath: IndexPath?

    init(viewModel: ChatViewModel, viewFactory: ViewFactory) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, viewFactory: viewFactory)
    }

    override public func loadView() {
        let view = viewFactory.makeChatView()
        self.view = view

        bind(viewModel: viewModel, to: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.event(.viewDidLoad)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // This is called to update message entry view height
        // on every font size change
        (self.view as? ChatView)?.messageEntryView.updateLayout()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return viewFactory.theme.chat.preferredStatusBarStyle
    }

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

    // swiftlint:disable function_body_length
    private func bind(viewModel: ChatViewModel, to view: ChatView) {
        view.header.showBackButton()
        view.header.showCloseButton()

        view.numberOfSections = { [weak viewModel] in
            viewModel?.numberOfSections
        }
        view.numberOfRows = { [weak viewModel] rows in
            viewModel?.numberOfItems(in: rows)
        }
        view.itemForRow = { [weak viewModel] row, section in
            viewModel?.item(for: row, in: section)
        }
        view.messageEntryView.textChanged = { [weak viewModel] text in
            viewModel?.event(.messageTextChanged(text))
        }
        view.messageEntryView.sendTapped = { [weak viewModel] in
            viewModel?.event(.sendTapped)
        }
        view.messageEntryView.pickMediaTapped = { [weak viewModel] in
            viewModel?.event(.pickMediaTapped)
        }
        view.messageEntryView.uploadListView.removeTapped = { [weak viewModel] upload in
            viewModel?.event(.removeUploadTapped(upload))
        }
        view.fileTapped = { [weak viewModel] file in
            viewModel?.event(.fileTapped(file))
        }
        view.downloadTapped = { [weak viewModel] download in
            viewModel?.event(.downloadTapped(download))
        }
        view.callBubbleTapped = { [weak viewModel] in
            viewModel?.event(.callBubbleTapped)
        }
        view.choiceOptionSelected = { [weak viewModel] option, messageId in
            viewModel?.event(.choiceOptionSelected(option, messageId))
        }
        view.chatScrolledToBottom = { [weak viewModel] bottomReached in
            viewModel?.event(.chatScrolled(bottomReached: bottomReached))
        }
        view.linkTapped = { [weak viewModel] url in
            viewModel?.event(.linkTapped(url))
        }
        view.selectCustomCardOption = { [weak viewModel] option, messageId in
            viewModel?.event(.customCardOptionSelected(option: option, messageId: messageId))
        }

        viewModel.action = { [weak self] action in
            switch action {
            case .queue:
                view.setConnectState(.queue, animated: false)
            case .connected(let name, let imageUrl):
                view.setConnectState(.connected(name: name, imageUrl: imageUrl), animated: true)
                view.unreadMessageIndicatorView.setImage(fromUrl: imageUrl, animated: true)
                view.messageEntryView.isConnected = true
            case .setMessageEntryEnabled(let enabled):
                view.messageEntryView.isEnabled = enabled
            case .setChoiceCardInputModeEnabled(let enabled):
                view.messageEntryView.isChoiceCardModeEnabled = enabled
            case .setMessageText(let text):
                view.messageEntryView.messageText = text
            case .sendButtonHidden(let hidden):
                view.messageEntryView.showsSendButton = !hidden
            case .pickMediaButtonEnabled(let enabled):
                view.messageEntryView.pickMediaButton.isEnabled = enabled
            case .appendRows(let count, let section, let animated):
                view.appendRows(count, to: section, animated: animated)
            case .refreshRow(let row, let section, let animated):
                view.refreshRow(row, in: section, animated: animated)
            case .refreshRows(let rows, let section, let animated):
                view.refreshRows(rows, in: section, animated: animated)
            case .refreshSection(let section):
                view.refreshSection(section)
            case .refreshAll:
                view.refreshAll()
            case .scrollToBottom(let animated):
                view.scrollToBottom(animated: animated)
            case .updateItemsUserImage(let animated):
                view.updateItemsUserImage(animated: animated)
            case .addUpload(let upload):
                view.messageEntryView.uploadListView.addUploadView(with: upload)
            case .removeUpload(let upload):
                view.messageEntryView.uploadListView.removeUploadView(with: upload)
            case .removeAllUploads:
                view.messageEntryView.uploadListView.removeAllUploadViews()
            case .presentMediaPicker(let itemSelected):
                self?.presentMediaPicker(
                    from: view.messageEntryView.pickMediaButton,
                    itemSelected: itemSelected
                )
            case .offerMediaUpgrade(let conf, let accepted, let declined):
                self?.offerMediaUpgrade(with: conf, accepted: accepted, declined: declined)
            case .showCallBubble(let imageUrl):
                view.showCallBubble(with: imageUrl, animated: true)
            case .updateUnreadMessageIndicator(let count):
                view.unreadMessageIndicatorView.newItemCount = count
            case .setOperatorTypingIndicatorIsHiddenTo(let isHidden, let isChatScrolledToBottom):
                if isChatScrolledToBottom {
                    view.scrollToBottom(animated: true)
                }
                view.setOperatorTypingIndicatorIsHidden(to: isHidden)
            case .setIsAttachmentButtonHidden(let isHidden):
                view.messageEntryView.isAttachmentButtonHidden = isHidden
            case .transferring:
                view.setConnectState(.transferring, animated: true)
            case .setCallBubbleImage(let imageUrl):
                view.setCallBubbleImage(with: imageUrl)
            case .setUnreadMessageIndicatorImage(let imageUrl):
                view.unreadMessageIndicatorView.setImage(fromUrl: imageUrl, animated: true)
            }
        }
    }

    private func presentMediaPicker(
        from sourceView: UIView,
        itemSelected: @escaping (AtttachmentSourceItemKind) -> Void
    ) {
        presentPopover(
            with: viewFactory.theme.chat.pickMedia,
            from: sourceView,
            arrowDirections: [.down],
            itemSelected: {
                self.dismiss(animated: true, completion: nil)
                itemSelected($0)
            }
        )
    }
}

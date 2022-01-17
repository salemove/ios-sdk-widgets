import MobileCoreServices
import UIKit

class ChatViewController: EngagementViewController, PopoverPresenter {
    private let viewModel: ChatViewModel
    private var lastVisibleRowIndexPath: IndexPath?

    init(viewModel: ChatViewModel, viewFactory: ViewFactory) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, viewFactory: viewFactory)
    }

    override public func loadView() {
        super.loadView()

        let view = viewFactory.makeChatView()
        self.view = view

        bind(viewModel: viewModel, to: view)
        bind(view: view, to: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.event(.viewDidLoad)
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
        viewModel.action = { [weak self, weak view] action in
            switch action {
            case .queue:
                view?.setConnectState(.queue, animated: false)
            case .connected(let name, let imageUrl):
                view?.setConnectState(.connected(name: name, imageUrl: imageUrl), animated: true)
                view?.unreadMessageIndicatorView.setImage(fromUrl: imageUrl, animated: true)
                view?.messageEntryView.isConnected = true
            case .setMessageEntryEnabled(let enabled):
                view?.messageEntryView.isEnabled = enabled
            case .setChoiceCardInputModeEnabled(let enabled):
                view?.messageEntryView.isChoiceCardModeEnabled = enabled
            case .setMessageText(let text):
                view?.messageEntryView.messageText = text
            case .sendButtonHidden(let hidden):
                view?.messageEntryView.showsSendButton = !hidden
            case .pickMediaButtonEnabled(let enabled):
                view?.messageEntryView.pickMediaButton.isEnabled = enabled
            case .appendRows(let count, let section, let animated):
                view?.appendRows(count, to: section, animated: animated)
            case .refreshRow(let row, let section, let animated):
                view?.refreshRow(row, in: section, animated: animated)
            case .refreshRows(let rows, let section, let animated):
                view?.refreshRows(rows, in: section, animated: animated)
            case .refreshSection(let section):
                view?.refreshSection(section)
            case .refreshAll:
                view?.refreshAll()
            case .scrollToBottom(let animated):
                view?.scrollToBottom(animated: animated)
            case .updateItemsUserImage(let animated):
                view?.updateItemsUserImage(animated: animated)
            case .addUpload(let upload):
                view?.messageEntryView.uploadListView.addUploadView(with: upload)
            case .removeUpload(let upload):
                view?.messageEntryView.uploadListView.removeUploadView(with: upload)
            case .removeAllUploads:
                view?.messageEntryView.uploadListView.removeAllUploadViews()
            case .presentMediaPicker(let itemSelected):
                guard let view = view else { return }

                self?.presentMediaPicker(
                    from: view.messageEntryView.pickMediaButton,
                    itemSelected: itemSelected
                )
            case .showCallBubble(let imageUrl):
                view?.showCallBubble(with: imageUrl, animated: true)
            case .updateUnreadMessageIndicator(let count):
                view?.unreadMessageIndicatorView.newItemCount = count
            case .setOperatorTypingIndicatorIsHiddenTo(let isHidden, let isChatScrolledToBottom):
                if isChatScrolledToBottom {
                    view?.scrollToBottom(animated: true)
                }

                view?.setOperatorTypingIndicatorIsHidden(to: isHidden)
            }
        }
    }

    private func bind(view: ChatView, to viewModel: ChatViewModel) {
        view.header.showBackButton()
        view.header.showCloseButton()

        view.numberOfSections = { [weak viewModel] in
            viewModel?.numberOfSections
        }
        view.numberOfRows = { [weak viewModel] in
            viewModel?.numberOfItems(in: $0)
        }
        view.itemForRow = { [weak viewModel] in
            viewModel?.item(for: $0, in: $1)
        }
        view.messageEntryView.textChanged = { [weak viewModel] in
            viewModel?.event(.messageTextChanged($0))
        }
        view.messageEntryView.sendTapped = { [weak viewModel] in
            viewModel?.event(.sendTapped)
        }
        view.messageEntryView.pickMediaTapped = { [weak viewModel] in
            viewModel?.event(.pickMediaTapped)
        }
        view.messageEntryView.uploadListView.removeTapped = { [weak viewModel] in
            viewModel?.event(.removeUploadTapped($0))
        }
        view.fileTapped = { [weak viewModel] in
            viewModel?.event(.fileTapped($0))
        }
        view.downloadTapped = { [weak viewModel] in
            viewModel?.event(.downloadTapped($0))
        }
        view.callBubbleTapped = { [weak viewModel] in
            viewModel?.event(.callBubbleTapped)
        }
        view.choiceOptionSelected = { [weak viewModel] in
            viewModel?.event(.choiceOptionSelected($0, $1))
        }
        view.chatScrolledToBottom = { [weak viewModel] in
            viewModel?.event(.chatScrolled(bottomReached: $0))
        }
        view.linkTapped = { [weak viewModel] in
            viewModel?.event(.linkTapped($0))
        }
        view.willDisplayItem = { [weak viewModel] in
            viewModel?.event(.willDisplayItem($0))
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
            itemSelected: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                itemSelected($0)
            }
        )
    }
}

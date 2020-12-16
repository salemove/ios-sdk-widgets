import UIKit

class ChatView: View {
    let header: Header
    let queueView: QueueView
    let messageEntryView: ChatMessageEntryView
    var numberOfRows: (() -> Int?)?
    var itemForRow: ((Int) -> ChatItem?)?
    var senderImageUrlForRow: ((Int) -> String?)?

    private let style: ChatStyle
    private let tableView = UITableView()
    private var messageEntryViewBottomConstraint: NSLayoutConstraint!
    private let keyboardObserver = KeyboardObserver()

    init(with style: ChatStyle) {
        self.style = style
        self.header = Header(with: style.header)
        self.queueView = QueueView(with: style.queue)
        self.messageEntryView = ChatMessageEntryView(with: style.messageEntry)
        super.init()
        setup()
        layout()
    }

    func appendRows(_ count: Int, animated: Bool) {
        guard let rowCount = numberOfRows?() else { return }

        if animated {
            let indexPaths = (rowCount - count ..< rowCount)
                .map({ IndexPath(row: $0, section: 0) })
            tableView.insertRows(at: indexPaths, with: .bottom)
        } else {
            tableView.reloadData()
        }
    }

    func refreshItems() {
        tableView.reloadData()
    }

    private func setup() {
        backgroundColor = style.backgroundColor

        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.register(cell: ChatItemCell.self)

        observeKeyboard()
    }

    private func layout() {
        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(with: .zero,
                                            excludingEdge: .bottom)

        addSubview(tableView)
        tableView.autoPinEdge(.top, to: .bottom, of: header)
        tableView.autoPinEdge(toSuperviewEdge: .left)
        tableView.autoPinEdge(toSuperviewEdge: .right)

        addSubview(messageEntryView)
        messageEntryViewBottomConstraint = messageEntryView.autoPinEdge(toSuperviewSafeArea: .bottom)
        messageEntryView.autoPinEdge(toSuperviewEdge: .left)
        messageEntryView.autoPinEdge(toSuperviewEdge: .right)
        messageEntryView.autoPinEdge(.top, to: .bottom, of: tableView)
    }
}

extension ChatView {
    private func observeKeyboard() {
        keyboardObserver.keyboardWillShow = { [unowned self] properties in
            let y = self.tableView.contentSize.height - properties.finalFrame.height
            let offset = CGPoint(x: 0, y: -y)

            UIView.animate(withDuration: properties.duration,
                           delay: 0.0,
                           options: properties.animationOptions,
                           animations: { [weak self] in
                let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
                self?.messageEntryViewBottomConstraint.constant = -properties.finalFrame.height + bottomInset
                self?.tableView.contentOffset = offset
                self?.layoutIfNeeded()
            }, completion: { _ -> Void in })
            messageEntryView.setSendButtonVisible(true, animated: true)
        }

        keyboardObserver.keyboardWillHide = { [unowned self] properties in
            UIView.animate(withDuration: properties.duration,
                           delay: 0.0,
                           options: properties.animationOptions,
                           animations: { [weak self] in
                self?.messageEntryViewBottomConstraint.constant = 0
                self?.layoutIfNeeded()
            }, completion: { _ -> Void in })
            messageEntryView.setSendButtonVisible(!messageEntryView.message.isEmpty,
                                                  animated: true)
        }
    }
}

extension ChatView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows?() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let item = itemForRow?(indexPath.row),
            let cell: ChatItemCell = tableView.dequeue(cellFor: indexPath)
        else { return UITableViewCell() }

        switch item.kind {
        case .queueOperator:
            cell.content = .queueOperator(queueView)
        case .sentMessage(let message):
            let view = SentChatMessageView(with: style.sentMessage)
            view.appendContent(.text(message.content), animated: false)
            cell.content = .sentMessage(view)
        case .receivedMessage(let message, _):
            let view = ReceivedChatMessageView(with: style.receivedMessage)
            view.appendContent(.text(message.content), animated: false)
            if let imageUrl = senderImageUrlForRow?(indexPath.row) {
                view.operatorImageView.setImage(fromUrl: imageUrl, animated: true)
            }
            cell.content = .receivedMessage(view)
        }

        return cell
    }
}

extension ChatView: UITableViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endEditing(true)
    }
}

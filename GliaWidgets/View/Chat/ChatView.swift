import UIKit

class ChatView: EngagementView {
    let messageEntryView: ChatMessageEntryView
    var numberOfSections: (() -> Int?)?
    var numberOfRows: ((Int) -> Int?)?
    var itemForRow: ((Int, Int) -> ChatItem?)?
    var callBubbleTapped: (() -> Void)?

    private let style: ChatStyle
    private let tableView = UITableView()
    private var messageEntryViewBottomConstraint: NSLayoutConstraint!
    private var callBubble: BubbleView?
    private let keyboardObserver = KeyboardObserver()

    private let kCallBubbleEdgeInset: CGFloat = 10
    private let kCallBubbleSize = CGSize(width: 60, height: 60)
    private var callBubbleBounds: CGRect {
        return CGRect(x: safeAreaInsets.left + kCallBubbleEdgeInset,
                      y: header.frame.size.height + kCallBubbleEdgeInset,
                      width: frame.size.width - safeAreaInsets.right - kCallBubbleEdgeInset,
                      height: messageEntryView.frame.origin.y - kCallBubbleEdgeInset)
    }

    init(with style: ChatStyle) {
        self.style = style
        self.messageEntryView = ChatMessageEntryView(with: style.messageEntry)
        super.init(with: style)
        setup()
        layout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        moveCallBubbleVisible(animated: true)
    }

    func setConnectState(_ state: ConnectView.State, animated: Bool) {
        connectView.setState(state, animated: animated)
        updateTableView(animated: animated)
    }

    func updateItemsUserImage(animated: Bool) {
        tableView.indexPathsForVisibleRows?.forEach({
            if let cell = tableView.cellForRow(at: $0) as? ChatItemCell,
               let item = itemForRow?($0.row, $0.section) {
                switch cell.content {
                case .operatorMessage(let view):
                    switch item.kind {
                    case .operatorMessage(_, showsImage: let showsImage, imageUrl: let imageUrl):
                        view.showsOperatorImage = showsImage
                        view.setOperatorImage(fromUrl: imageUrl, animated: animated)
                    default:
                        break
                    }
                default:
                    break
                }
            }
        })
    }

    func appendRows(_ count: Int, to section: Int, animated: Bool) {
        guard let rows = numberOfRows?(section) else { return }

        if animated {
            let indexPaths = (rows - count ..< rows)
                .map({ IndexPath(row: $0, section: section) })
            tableView.insertRows(at: indexPaths, with: .bottom)
        } else {
            tableView.reloadData()
        }
    }

    func scrollToBottom(animated: Bool) {
        tableView.scrollToBottom(animated: animated)
    }

    func refreshRow(_ row: Int, in section: Int, animated: Bool) {
        let indexPath = IndexPath(row: row, section: section)

        guard
            tableView.indexPathsForVisibleRows?.contains(indexPath) == true,
            let cell = tableView.cellForRow(at: indexPath) as? ChatItemCell,
            let item = itemForRow?(indexPath.row, indexPath.section)
        else { return }

        cell.content = content(for: item)
        updateTableView(animated: animated)
    }

    func refreshSection(_ section: Int) {
        tableView.reloadSections([section], with: .fade)
    }

    func refreshAll() {
        tableView.reloadData()
    }

    private func setup() {
        header.title = style.title

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
        tableView.autoPinEdge(.top, to: .bottom, of: header, withOffset: 10)
        tableView.autoPinEdge(toSuperviewSafeArea: .left)
        tableView.autoPinEdge(toSuperviewSafeArea: .right)

        addSubview(messageEntryView)
        messageEntryViewBottomConstraint = messageEntryView.autoPinEdge(toSuperviewSafeArea: .bottom)
        messageEntryView.autoPinEdge(toSuperviewSafeArea: .left)
        messageEntryView.autoPinEdge(toSuperviewSafeArea: .right)
        messageEntryView.autoPinEdge(.top, to: .bottom, of: tableView, withOffset: 10)
    }

    private func content(for item: ChatItem) -> ChatItemCell.Content {
        switch item.kind {
        case .queueOperator:
            return .queueOperator(connectView)
        case .outgoingMessage(let message):
            let view = VisitorChatMessageView(with: style.visitorMessage)
            view.appendContent(.text(message.content), animated: false)
            return .outgoingMessage(view)
        case .visitorMessage(let message, status: let status):
            let view = VisitorChatMessageView(with: style.visitorMessage)
            view.appendContent(.text(message.content), animated: false)
            view.status = status
            return .visitorMessage(view)
        case .operatorMessage(let message, showsImage: let showsImage, imageUrl: let imageUrl):
            let view = OperatorChatMessageView(with: style.operatorMessage)
            view.appendContent(.text(message.content), animated: false)
            view.showsOperatorImage = showsImage
            view.setOperatorImage(fromUrl: imageUrl, animated: false)
            return .operatorMessage(view)
        }
    }

    private func updateTableView(animated: Bool) {
        if animated {
            tableView.beginUpdates()
            tableView.endUpdates()
        } else {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
}

extension ChatView {
    func showCallBubble(with imageUrl: String?, animated: Bool) {
        guard callBubble == nil else { return }

        let callBubble = BubbleView(with: style.callBubble)
        callBubble.kind = .userImage(url: imageUrl)
        callBubble.tap = { [weak self] in self?.callBubbleTapped?() }
        callBubble.frame = CGRect(origin: CGPoint(x: callBubbleBounds.width - kCallBubbleSize.width,
                                                  y: callBubbleBounds.height - kCallBubbleSize.height),
                                  size: kCallBubbleSize)
        self.callBubble = callBubble
        addSubview(callBubble)
    }

    private func moveCallBubbleVisible(animated: Bool) {
        guard let callBubble = callBubble else { return }
        bringSubviewToFront(callBubble)
    }
}

extension ChatView {
    private func observeKeyboard() {
        keyboardObserver.keyboardWillShow = { [unowned self] properties in
            let y = self.tableView.contentSize.height - properties.finalFrame.height
            let offset = CGPoint(x: 0, y: y)

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
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections?() ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows?(section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let item = itemForRow?(indexPath.row, indexPath.section),
            let cell: ChatItemCell = tableView.dequeue(cellFor: indexPath)
        else { return UITableViewCell() }

        cell.content = content(for: item)

        return cell
    }
}

extension ChatView: UITableViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endEditing(true)
    }
}

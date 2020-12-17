import UIKit

class ChatView: View {
    let header: Header
    let queueView: QueueView
    let messageEntryView: ChatMessageEntryView
    var numberOfSections: (() -> Int?)?
    var numberOfRows: ((Int) -> Int?)?
    var itemForRow: ((Int, Int) -> ChatItem?)?
    var userImageUrlForRow: ((Int, Int) -> String?)?

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

    func refreshRow(_ row: Int, in section: Int) {
        let indexPath = IndexPath(row: row, section: section)

        guard
            let cell = tableView.cellForRow(at: indexPath) as? ChatItemCell,
            let item = itemForRow?(indexPath.row, indexPath.section)
        else { return }

        cell.content = content(for: item)
    }

    func refreshAll() {
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

    private func content(for item: ChatItem) -> ChatItemCell.Content {
        switch item.kind {
        case .queueOperator:
            return .queueOperator(queueView)
        case .outgoingMessage(let message):
            let view = VisitorChatMessageView(with: style.visitorMessage)
            view.appendContent(.text(message.content), animated: false)
            return .outgoingMessage(view)
        case .visitorMessage(let message, status: let status):
            let view = VisitorChatMessageView(with: style.visitorMessage)
            view.appendContent(.text(message.content), animated: false)
            view.status = status
            return .visitorMessage(view)
        case .operatorMessage(let message):
            let view = OperatorChatMessageView(with: style.operatorMessage)
            view.appendContent(.text(message.content), animated: false)
            view.showsOperatorImage = true
            return .operatorMessage(view)
        }
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

        switch item.kind {
        case .operatorMessage(let message):
            /*if let imageUrl = userImageUrlForRow?(indexPath.row, indexPath.section) {
                view.operatorImageView.setImage(fromUrl: imageUrl, animated: true)
            }*/
            break
        default:
            break
        }

        return cell
    }
}

extension ChatView: UITableViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endEditing(true)
    }
}

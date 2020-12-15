import UIKit

class ChatView: View {
    let header: Header
    let queueView: QueueView

    var numberOfRows: (() -> Int?)?
    var itemForRow: ((Int) -> ChatItem?)?

    private let style: ChatStyle
    private let tableView = UITableView()
    private let messageEntryView: ChatMessageEntryView
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
        if animated {
            let indexPaths = (0 ..< count)
                .map({ IndexPath(row: $0, section: 0) })
            tableView.insertRows(at: indexPaths, with: .top)
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
        tableView.estimatedRowHeight = 200
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

        tableView.tableHeaderView = queueView
        queueView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        queueView.autoAlignAxis(toSuperviewAxis: .vertical)

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
        }

        keyboardObserver.keyboardWillHide = { [unowned self] properties in
            UIView.animate(withDuration: properties.duration,
                           delay: 0.0,
                           options: properties.animationOptions,
                           animations: { [weak self] in
                self?.messageEntryViewBottomConstraint.constant = 0
                self?.layoutIfNeeded()
            }, completion: { _ -> Void in })
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
        case .sentMessage:
            let view = SentChatMessageView(with: style.sentMessage)
            cell.content = .sentMessage(view)
        }

        return cell
    }
}

extension ChatView: UITableViewDelegate {

}

import UIKit

class ChatView: View {
    let header: Header
    let queueView: QueueView

    var numberOfRows: (() -> Int?)?
    var itemForRow: ((Int) -> ChatItem?)?

    private let style: ChatStyle
    private let tableView = UITableView()

    init(with style: ChatStyle) {
        self.style = style
        self.header = Header(with: style.header)
        self.queueView = QueueView(with: style.queue)
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
    }

    private func layout() {
        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(with: .zero,
                                            excludingEdge: .bottom)

        addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        tableView.autoPinEdge(.top, to: .bottom, of: header)

        tableView.tableHeaderView = queueView
        queueView.autoPinEdgesToSuperviewEdges()
        queueView.autoAlignAxis(toSuperviewAxis: .vertical)
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

        switch item.kind {}

        return cell
    }
}

extension ChatView: UITableViewDelegate {

}

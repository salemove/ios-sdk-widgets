import UIKit

// MARK: - UITableViewDataSource

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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard
            let cell = cell as? ChatItemCell,
            case .customCard(let view) = cell.content
        else { return }
        view.willDisplayView?()
    }
}

// MARK: - UITableViewDelegate

extension ChatView: UITableViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endEditing(true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        chatScrolledToBottom?(isBottomReached(for: scrollView))
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = itemForRow?(indexPath.row, indexPath.section) else { return CGFloat.zero }
        guard case .none = content(for: item) else { return UITableView.automaticDimension }
        return CGFloat.zero
    }
}

import UIKit
import GliaWidgets
import GliaCoreSDK

extension ViewController {
    @IBAction func showUpdateVisitorInfo() {
        let controller = VisitorInfoViewController()
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen

        self.present(navController, animated: true) { [weak self] in
            self?.visitorInfoModel.loadVisitorInfo()
        }

        visitorInfoModel.delegate = { [weak navController, weak controller] delegateAction in
            switch delegateAction {
            case .cancel:
                navController?.presentingViewController?.dismiss(animated: true)
            case let .renderProps(props):
                controller?.props = props
            }
        }
    }
}

final class VisitorInfoViewController: UIViewController {
    private lazy var tableView = UITableView()
    private var tableViewBottomConstraint: NSLayoutConstraint?
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var refreshControl = UIRefreshControl()
    private lazy var cancelBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .close,
        target: self,
        action: #selector(handleCancelTap)
    )
    private lazy var updateBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .save,
        target: self,
        action: #selector(handleUpdateTap)
    )
    private lazy var loadingBarButtonItem: UIBarButtonItem = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        let barButtonItem = UIBarButtonItem(customView: activityIndicator)
        return barButtonItem
    }()

    var props = Props(
        title: "",
        sections: [],
        pulledToRefresh: .nop,
        showsRefreshing: false,
        cancelButton: .init(tap: .nop, accIdentifier: ""),
        updateButton: .loading
    ) {
        didSet {
            updateProps()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCancelButton()
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
    }

    private func setupTableView() {
        view.addSubview(tableView)
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)

        tableView.refreshControl = refreshControl
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate(
            [
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableViewBottomConstraint
            ].compactMap { $0 }
        )
        tableView.register(InfoFieldCell.self, forCellReuseIdentifier: InfoFieldCell.identifier)
        tableView.register(NotesCell.self, forCellReuseIdentifier: NotesCell.identifier)
        tableView.register(CustomAttributeCell.self, forCellReuseIdentifier: CustomAttributeCell.identifier)
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    func setupCancelButton() {
        self.navigationItem.leftBarButtonItem = cancelBarButtonItem
    }

    func updateProps() {
        title = props.title
        let visibleCells = tableView.visibleCells
        var hasResponder = false
        // We should skip reloading cells with responder, to avoid
        // keyboard being dismissed because of cell reuse.
        // Instead we find cell that has 'firstResponder'
        // and render it directly.
        for cell in visibleCells where cell.isKeyboardPresented() {
            hasResponder = true
            guard let indexPath = tableView.indexPath(for: cell) else { break }
            switch props.sections[indexPath.section] {
            case let .fields(_, fields):
                if let cellType = CellType(cell) {
                    CellType.renderCell(cellType, infoField: fields[indexPath.row])
                }
            case let .notes(_, note):
                if let cellType = CellType(cell) {
                    CellType.renderCell(cellType, infoField: note)
                    // We need to ask table view to recompute cell,
                    // to adjust its height to the height requested
                    // by text view if needed.
                    // This can crash if changes have been done
                    // to table view in parallel to these method calls,
                    // so maybe additional checks may be necessary.
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            case let .customAttributes(_, attributes):
                if let cellType = CellType(cell) {
                    CellType.renderCell(cellType, infoField: attributes[indexPath.row])
                }
            }
        }
        // If cells do not contain 'firstResponder' views,
        // we just reload visible cells, to let them be rendered
        // during cell reuse phase.
        if !hasResponder {
            tableView.reloadData()
        }

        self.cancelBarButtonItem.accessibilityIdentifier = props.cancelButton.accIdentifier
        self.renderedShowsRefreshing = props.showsRefreshing
        self.renderedUpdateButton = props.updateButton
    }

    @objc func handlePullToRefresh() {
        if tableView.isKeyboardPresented() {
            tableView.endEditing(true)
        }
        props.pulledToRefresh()
    }

    @objc func handleCancelTap() {
        props.cancelButton.tap()
    }

    @objc func handleUpdateTap() {
        guard !tableView.isKeyboardPresented() else {
            tableView.endEditing(true)
            return
        }
        Props.UIUpdateButton(props.updateButton).tap?()
    }

    private var renderedShowsRefreshing: Bool = false {
        didSet {
            guard oldValue != renderedShowsRefreshing else { return }
            if renderedShowsRefreshing {
                if !self.refreshControl.isRefreshing {
                    self.refreshControl.beginRefreshing()
                }
            } else {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    private var renderedUpdateButton: Props.UpdateButton = .loading {
        didSet {
            guard oldValue != renderedUpdateButton else { return }
            switch self.renderedUpdateButton {
            case let .normal(_, isEnabled, accIdentifier):
                self.navigationItem.rightBarButtonItem = self.updateBarButtonItem
                self.updateBarButtonItem.isEnabled = isEnabled
                self.updateBarButtonItem.accessibilityIdentifier = accIdentifier
            case .loading:
                self.navigationItem.rightBarButtonItem = self.loadingBarButtonItem
            }

        }
    }
}

extension VisitorInfoViewController {
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: selector,
            name: notification,
            object: nil
        )
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] {
            tableViewBottomConstraint?.constant = 0
            let duration = (durationValue as AnyObject).doubleValue ?? 0.3
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey],
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] {
            let endRect = self.view.convert((endValue as AnyObject).cgRectValue, from: self.view.window)
            tableViewBottomConstraint?.constant = -endRect.height
            let duration = (durationValue as AnyObject).doubleValue ?? 0.3
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
            if let responderView = tableView.visibleCells.first(where: { $0.isKeyboardPresented() }) {
                tableView.scrollRectToVisible(responderView.frame, animated: true)
            }
        }
    }
}

extension VisitorInfoViewController {
    struct Props: Equatable {
        let title: String
        let sections: [Section]
        let pulledToRefresh: Cmd
        let showsRefreshing: Bool
        let cancelButton: CancelButton
        let updateButton: UpdateButton
    }
}

extension VisitorInfoViewController.Props {
    struct UIUpdateButton {
        let tap: Cmd?

        init(_ updateButton: UpdateButton) {
            switch updateButton {
            case let .normal(tap, _, _):
                self.tap = tap
            case .loading:
                tap = nil
            }
        }
    }

    struct CancelButton: Equatable {
        let tap: Cmd
        let accIdentifier: String
    }
}

extension VisitorInfoViewController.Props {
    typealias KeyValuePair = InfoField.CustomAttributesUpdateMethod.KeyValuePair

    enum InfoField: Hashable {
        case name(label: String, value: String, update: Command<String>)
        case email(label: String, value: String, update: Command<String>)
        case phoneNumber(label: String, value: String, update: Command<String>)
        case notes(placeholder: String, text: String, update: Command<String>)
        case customAttributes(KeyValuePair)
    }

    enum Section: Equatable {
        case fields(title: HeaderView.Props, fields: [InfoField])
        case notes(title: HeaderView.Props, notes: InfoField)
        case customAttributes(title: HeaderView.Props, attributes: [InfoField])
    }

    enum UpdateButton: Equatable {
        case normal(Cmd, isEnabled: Bool, accIdentifier: String)
        case loading
    }
}

extension VisitorInfoViewController.Props.InfoField {
    var isRemovable: Bool {
        switch self {
        case .customAttributes:
            return true
        case .email, .name, .phoneNumber, .notes:
            return false
        }
    }
}

extension VisitorInfoViewController.Props.InfoField {
    enum NotesUpdateMethod: Hashable {
        case replace
        case append
    }

    enum CustomAttributesUpdateMethod: Hashable {
        case replace
        case merge
    }
}

extension VisitorInfoViewController.Props.InfoField.NotesUpdateMethod {
    func label() -> String {
        switch self {
        case .append:
            return "Append"
        case .replace:
            return "Replace"
        }
    }
}

extension VisitorInfoViewController.Props.InfoField.CustomAttributesUpdateMethod {
    struct KeyValuePair: Hashable {
        let key: String
        let keyUpdate: Command<String>
        let value: String
        let valueUpdate: Command<String>
        let remove: Cmd
        let keyFieldAccIdentifier: String
        let valueFieldAccIdentifier: String
    }
}

extension VisitorInfoViewController.Props.InfoField.CustomAttributesUpdateMethod {
    func label() -> String {
        switch self {
        case .replace:
            return "Replace"
        case .merge:
            return "Merge"
        }
    }
}

extension VisitorInfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        props.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch props.sections[section] {
        case let .fields(_, items):
            return items.count
        case .notes:
            return 1
        case let .customAttributes(_, attributes):
            return attributes.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch props.sections[indexPath.section] {
        case let .fields(_, fields):
            let field = fields[indexPath.row]
            if let cell = CellType.dequeueCell(for: field, from: tableView, at: indexPath) {
                CellType.renderCell(cell, infoField: field)
                return cell.cell()
            } else {
                return UITableViewCell()
            }
        case let .notes(_, note):
            if let cell = CellType.dequeueCell(for: note, from: tableView, at: indexPath) {
                CellType.renderCell(cell, infoField: note)
                return cell.cell()
            } else {
                return UITableViewCell()
            }
        case let .customAttributes(_, attributes):
            let attribute = attributes[indexPath.row]
            if let cell = CellType.dequeueCell(for: attribute, from: tableView, at: indexPath) {
                CellType.renderCell(cell, infoField: attribute)
                return cell.cell()
            } else {
                return UITableViewCell()
            }
        }
    }
}

extension VisitorInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView
            .dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as? HeaderView

        switch props.sections[section] {
        case let .fields(headerProps, _):
            header?.props = headerProps

        case let .notes(notesProps, _):
            header?.props = notesProps
        case let .customAttributes(headerProps, _):
            header?.props = headerProps
        }

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        HeaderView.height
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch self.props.sections[indexPath.section] {
        case let .customAttributes(_, attributes):
            let isRemovable = attributes[indexPath.row].isRemovable

            if isRemovable && tableView.isKeyboardPresented() {
                tableView.endEditing(true)
                return .none
            }

            return isRemovable ? .delete : .none
        case .fields, .notes:
            return .none
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch self.props.sections[indexPath.section] {
        case let .customAttributes(_, attributes):
            switch attributes[indexPath.row] {
            case let .customAttributes(pair):
                pair.remove()
            case .email, .name, .notes, .phoneNumber:
                break
            }
        case .fields, .notes:
            break
        }
    }
}

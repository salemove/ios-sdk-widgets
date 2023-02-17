#if DEBUG
import GliaWidgets
import UIKit

// This view controller used for presenting Playbook items
//  and showing during development.
final class PlaybookViewController: UIViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() { super.init(nibName: nil, bundle: nil) }

    override func loadView() {
        view = PlaybookView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
    }

    var contentView: PlaybookView {
        view as! PlaybookView
    }

    let dataSource = ViewPlaybook.all
}

extension PlaybookViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playbook-cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "playbook-cell")
        cell.textLabel?.text = dataSource[indexPath.row].title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        let preview = item.preview()
        let vc = UIViewController()
        vc.title = item.title
        vc.view.backgroundColor = .white
        navigationController?.pushViewController(vc, animated: true)

        let scrollView = UIScrollView()
        vc.view.addSubview(scrollView)
        scrollView.addSubview(preview)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        preview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor),
            preview.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            preview.topAnchor.constraint(equalTo: scrollView.topAnchor),
            preview.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            preview.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
}

final class PlaybookView: UIView {
    let tableView = UITableView()

    required init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        backgroundColor = .white
    }

    func defineLayout() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    override func updateConstraints() {
        if defineLayoutIsNeeded {
            defineLayoutIsNeeded = false
            defineLayout()
        }
        super.updateConstraints()
    }

    // MARK: - Private

    private var defineLayoutIsNeeded = true
}
#endif

import UIKit
import GliaWidgets

class SettingsViewController: UIViewController {
    private let tableView = UITableView()
    private var cells = [SettingsCell]()
    private var primaryColorCell: SettingsColorCell!

    var theme: Theme = Theme()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .white

        let doneItem = UIBarButtonItem(title: "Done",
                                       style: .done,
                                       target: self,
                                       action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneItem

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50

        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea()

        createCells()
    }

    private func createCells() {
        primaryColorCell = SettingsColorCell(title: "Primary color:",
                                             color: theme.color.primary)
        cells.append(primaryColorCell)

        tableView.reloadData()
    }

    @objc private func doneTapped() {
        let color = ThemeColor(primary: primaryColorCell.color)
        let colorStyle: ThemeColorStyle = .custom(color)
        theme = Theme(colorStyle: colorStyle)
        // create theme
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
}

extension SettingsViewController: UITableViewDelegate {}

import UIKit
import GliaWidgets

private struct Section {
    let title: String
    let cells: [SettingsCell]
}

class SettingsViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var sections = [Section]()
    private var primaryColorCell: SettingsColorCell!
    private var secondaryColorCell: SettingsColorCell!
    private var baseNormalColorCell: SettingsColorCell!
    private var baseLightColorCell: SettingsColorCell!
    private var baseDarkColorCell: SettingsColorCell!
    private var baseShadeColorCell: SettingsColorCell!
    private var backgroundColorCell: SettingsColorCell!
    private var systemNegativeColorCell: SettingsColorCell!

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
        primaryColorCell = SettingsColorCell(title: "Primary:",
                                             color: theme.color.primary)
        secondaryColorCell = SettingsColorCell(title: "Secondary:",
                                               color: theme.color.secondary)
        baseNormalColorCell = SettingsColorCell(title: "Base normal:",
                                                color: theme.color.baseNormal)
        baseLightColorCell = SettingsColorCell(title: "Base light:",
                                               color: theme.color.baseLight)
        baseDarkColorCell = SettingsColorCell(title: "Base dark:",
                                              color: theme.color.baseDark)
        baseShadeColorCell = SettingsColorCell(title: "Base shade:",
                                               color: theme.color.baseShade)
        backgroundColorCell = SettingsColorCell(title: "Background:",
                                                color: theme.color.background)
        systemNegativeColorCell = SettingsColorCell(title: "System negative:",
                                                    color: theme.color.systemNegative)
        var colorCells = [SettingsColorCell]()
        colorCells.append(primaryColorCell)
        colorCells.append(secondaryColorCell)
        colorCells.append(baseNormalColorCell)
        colorCells.append(baseLightColorCell)
        colorCells.append(baseDarkColorCell)
        colorCells.append(baseShadeColorCell)
        colorCells.append(backgroundColorCell)
        colorCells.append(systemNegativeColorCell)

        let colorSection = Section(title: "Theme colors (RRGGBBAA)",
                                   cells: colorCells)

        sections.append(colorSection)

        tableView.reloadData()
    }

    private func makeTheme() -> Theme {
        let color = ThemeColor(primary: primaryColorCell.color,
                               secondary: secondaryColorCell.color,
                               baseNormal: baseNormalColorCell.color,
                               baseLight: baseLightColorCell.color,
                               baseDark: baseDarkColorCell.color,
                               baseShade: baseShadeColorCell.color,
                               background: backgroundColorCell.color,
                               systemNegative: systemNegativeColorCell.color)
        let colorStyle: ThemeColorStyle = .custom(color)
        return Theme(colorStyle: colorStyle)
    }

    @objc private func doneTapped() {
        theme = makeTheme()
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].cells[indexPath.row]
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

extension SettingsViewController: UITableViewDelegate {}

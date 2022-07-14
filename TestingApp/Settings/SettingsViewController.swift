import UIKit
import GliaWidgets

private struct Section {
    let title: String
    let cells: [SettingsCell]
}

final class SettingsViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var sections = [Section]()
    private var siteApiKeyIdCell: SettingsTextCell!
    private var siteApiKeySecretCell: SettingsTextCell!
    private var siteCell: SettingsTextCell!
    private var queueIDCell: SettingsTextCell!
    private var environmentCell: EnvironmentSettingsTextCell!
    private var visitorContextAssedIdCell: SettingsTextCell!
    private var bubbleFeatureCell: SettingsSwitchCell!
    private var primaryColorCell: SettingsColorCell!
    private var secondaryColorCell: SettingsColorCell!
    private var baseNormalColorCell: SettingsColorCell!
    private var baseLightColorCell: SettingsColorCell!
    private var baseDarkColorCell: SettingsColorCell!
    private var baseShadeColorCell: SettingsColorCell!
    private var backgroundColorCell: SettingsColorCell!
    private var systemNegativeColorCell: SettingsColorCell!
    private var header1FontCell: SettingsFontCell!
    private var header2FontCell: SettingsFontCell!
    private var header3FontCell: SettingsFontCell!
    private var bodyTextFontCell: SettingsFontCell!
    private var subtitleFontCell: SettingsFontCell!
    private var mediumSubtitle1FontCell: SettingsFontCell!
    private var mediumSubtitle2FontCell: SettingsFontCell!
    private var captionFontCell: SettingsFontCell!
    private var buttonLabelFontCell: SettingsFontCell!

    private var configurationSection = Section(
        title: "Glia configuration",
        cells: []
    )

    private var props: Props

    init(props: Props) {
        self.props = props
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .white

        let doneItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        doneItem.accessibilityIdentifier = "screen_settings_barButtonItem_done"
        navigationItem.rightBarButtonItem = doneItem

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50

        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea()

        createCells()
        updateConfigurationSection()
    }

    @objc
    func authMethodDidChange(sender: UISegmentedControl) {
        updateConfigurationSection()
        tableView.reloadData()
    }

    @objc
    private func doneTapped() {
        updateConfiguration()
        props.changeTheme(makeTheme())
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private
private extension SettingsViewController {
    // swiftlint:disable function_body_length
    private func createCells() {
        siteApiKeyIdCell = SettingsTextCell(
            title: "Identifier:",
            text: props.config.siteApiKeyId
        )
        siteApiKeyIdCell.textField.accessibilityIdentifier = "settings_siteApiKeyId_textfield"
        siteApiKeySecretCell = SettingsTextCell(
            title: "Secret:",
            text: props.config.siteApiKeySecret
        )
        siteApiKeySecretCell.textField.accessibilityIdentifier = "settings_siteApiKeySecret_textfield"
        siteCell = SettingsTextCell(
            title: "Site:",
            text: props.config.site
        )
        siteCell.textField.accessibilityIdentifier = "settings_siteId_textfield"
        queueIDCell = SettingsTextCell(
            title: "Queue ID:",
            text: props.queueId
        )
        queueIDCell.textField.accessibilityIdentifier = "settings_queueId_textfield"
        environmentCell = EnvironmentSettingsTextCell(
            title: "Environment:",
            environment: props.config.environment
        )
        environmentCell.customEnvironmentUrlTextField.accessibilityIdentifier = "settings_custom_environment_url_textfield"
        visitorContextAssedIdCell = SettingsTextCell(
            title: "Visitor Context Asset ID:",
            text: props.config.visitorContext?.assetId.uuidString ?? ""
        )
        visitorContextAssedIdCell.textField.accessibilityIdentifier = "settings_visitor_context_assetId_textfield"
        bubbleFeatureCell = SettingsSwitchCell(
            title: "Present \"Bubble\" overlay in engagement time",
            isOn: props.features ~= .bubbleView
        )
        let featuresSection = Section(
            title: "Features",
            cells: [bubbleFeatureCell]
        )

        primaryColorCell = SettingsColorCell(
            title: "Primary:",
            color: props.theme.color.primary
        )
        secondaryColorCell = SettingsColorCell(
            title: "Secondary:",
            color: props.theme.color.secondary
        )
        baseNormalColorCell = SettingsColorCell(
            title: "Base normal:",
            color: props.theme.color.baseNormal
        )
        baseLightColorCell = SettingsColorCell(
            title: "Base light:",
            color: props.theme.color.baseLight
        )
        baseDarkColorCell = SettingsColorCell(
            title: "Base dark:",
            color: props.theme.color.baseDark
        )
        baseShadeColorCell = SettingsColorCell(
            title: "Base shade:",
            color: props.theme.color.baseShade
        )
        backgroundColorCell = SettingsColorCell(
            title: "Background:",
            color: props.theme.color.background
        )
        systemNegativeColorCell = SettingsColorCell(
            title: "System negative:",
            color: props.theme.color.systemNegative
        )
        var colorCells = [SettingsCell]()
        colorCells.append(primaryColorCell)
        colorCells.append(secondaryColorCell)
        colorCells.append(baseNormalColorCell)
        colorCells.append(baseLightColorCell)
        colorCells.append(baseDarkColorCell)
        colorCells.append(baseShadeColorCell)
        colorCells.append(backgroundColorCell)
        colorCells.append(systemNegativeColorCell)

        let colorSection = Section(
            title: "Theme colors (RRGGBB Alpha)",
            cells: colorCells
        )

        header1FontCell = SettingsFontCell(
            title: "Header1",
            defaultFont: props.theme.font.header1
        )
        header2FontCell = SettingsFontCell(
            title: "Header2",
            defaultFont: props.theme.font.header2
        )
        header3FontCell = SettingsFontCell(
            title: "Header3",
            defaultFont: props.theme.font.header3
        )
        bodyTextFontCell = SettingsFontCell(
            title: "Body text",
            defaultFont: props.theme.font.bodyText
        )
        subtitleFontCell = SettingsFontCell(
            title: "Subtitle",
            defaultFont: props.theme.font.subtitle
        )
        mediumSubtitle1FontCell = SettingsFontCell(
            title: "Medium subtitle1",
            defaultFont: props.theme.font.mediumSubtitle1
        )
        mediumSubtitle2FontCell = SettingsFontCell(
            title: "Medium subtitle2",
            defaultFont: props.theme.font.mediumSubtitle2
        )
        captionFontCell = SettingsFontCell(
            title: "Caption",
            defaultFont: props.theme.font.caption
        )
        buttonLabelFontCell = SettingsFontCell(
            title: "Button label",
            defaultFont: props.theme.font.buttonLabel
        )
        var fontCells = [SettingsCell]()
        fontCells.append(header1FontCell)
        fontCells.append(header2FontCell)
        fontCells.append(header3FontCell)
        fontCells.append(bodyTextFontCell)
        fontCells.append(subtitleFontCell)
        fontCells.append(mediumSubtitle1FontCell)
        fontCells.append(mediumSubtitle2FontCell)
        fontCells.append(captionFontCell)
        fontCells.append(buttonLabelFontCell)

        let fontSection = Section(title: "Fonts",
                                  cells: fontCells)

        sections.append(configurationSection)
        sections.append(featuresSection)
        sections.append(colorSection)
        sections.append(fontSection)

        tableView.reloadData()
    }

    private func updateConfigurationSection() {
        let cells: [SettingsCell] = [
            environmentCell,
            siteCell,
            siteApiKeyIdCell,
            siteApiKeySecretCell,
            queueIDCell,
            visitorContextAssedIdCell
        ]
        configurationSection = Section(
            title: "Glia configuration",
            cells: cells
        )
        sections[0] = configurationSection
    }

    private func updateConfiguration() {
        let uuid = UUID(uuidString: visitorContextAssedIdCell.textField.text ?? "")

        props.changeConfig(
            Configuration(
                authorizationMethod: siteApiKey,
                environment: environmentCell.environment,
                site: siteCell.textField.text ?? "",
                visitorContext: uuid.map { Configuration.VisitorContext(assetId: $0) }
            )
        )

        var features = Features.all
        if !bubbleFeatureCell.switcher.isOn {
            features.remove(.bubbleView)
        }
        props.changeFeatures(features)
        props.changeQueueId(queueIDCell.textField.text ?? "")
    }

    private var siteApiKey: Configuration.AuthorizationMethod {
        .siteApiKey(
            id: siteApiKeyIdCell.textField.text ?? "",
            secret: siteApiKeySecretCell.textField.text ?? ""
        )
    }

    private func makeTheme() -> Theme {
        let color = ThemeColor(
            primary: primaryColorCell.color,
            secondary: secondaryColorCell.color,
            baseNormal: baseNormalColorCell.color,
            baseLight: baseLightColorCell.color,
            baseDark: baseDarkColorCell.color,
            baseShade: baseShadeColorCell.color,
            background: backgroundColorCell.color,
            systemNegative: systemNegativeColorCell.color
        )
        let font = ThemeFont(
            header1: header1FontCell.selectedFont,
            header2: header2FontCell.selectedFont,
            header3: header3FontCell.selectedFont,
            bodyText: bodyTextFontCell.selectedFont,
            subtitle: subtitleFontCell.selectedFont,
            mediumSubtitle1: mediumSubtitle1FontCell.selectedFont,
            mediumSubtitle2: mediumSubtitle2FontCell.selectedFont,
            caption: captionFontCell.selectedFont,
            buttonLabel: buttonLabelFontCell.selectedFont
        )

        let colorStyle: ThemeColorStyle = .custom(color)
        let fontStyle: ThemeFontStyle = .custom(font)

        return Theme(
            colorStyle: colorStyle,
            fontStyle: fontStyle
        )
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

private extension Configuration {

    var siteApiKeyId: String {
        switch authorizationMethod {
        case .siteApiKey(let id, _):
            return id
        default:
            return ""
        }
    }

    var siteApiKeySecret: String {
        switch authorizationMethod {
        case .siteApiKey(_, let secret):
            return secret
        default:
            return ""
        }
    }
}

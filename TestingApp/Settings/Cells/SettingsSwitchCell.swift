import UIKit

final class SettingsSwitchCell: SettingsCell {
    let switcher = UISwitch()

    init(title: String, isOn: Bool) {
        switcher.isOn = isOn
        super.init(title: title)
        layout()
    }

    private func layout() {
        contentView.addSubview(switcher)
        switcher.autoPinEdge(.left, to: .right, of: titleLabel, withOffset: 10, relation: .greaterThanOrEqual)
        switcher.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20),
                                              excludingEdge: .left)
    }
}

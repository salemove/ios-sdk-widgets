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

final class SettingsSegmentedCell: SettingsCell {
    let segmentedControl: UISegmentedControl

    init(title: String, items: String...) {
        self.segmentedControl = .init(items: items.map(NSString.init(string:)))
        super.init(title: title)
        layout()
    }

    private func layout() {
        contentView.addSubview(segmentedControl)
        segmentedControl.autoPinEdge(.left, to: .right, of: titleLabel, withOffset: 10, relation: .greaterThanOrEqual)
        segmentedControl.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20),
                                              excludingEdge: .left)
    }
}

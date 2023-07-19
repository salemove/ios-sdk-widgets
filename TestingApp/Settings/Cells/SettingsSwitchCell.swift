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
        switcher.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20)
        constraints += switcher.layoutInSuperview(edges: .vertical, insets: insets)
        constraints += switcher.layoutInSuperview(edges: .trailing, insets: insets)
        constraints += switcher.leadingAnchor.constraint(
            equalTo: titleLabel.trailingAnchor,
            constant: 10
        )
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
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        let insets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20)
        constraints += segmentedControl.layoutInSuperview(edges: .vertical, insets: insets)
        constraints += segmentedControl.layoutInSuperview(edges: .trailing, insets: insets)
        constraints += segmentedControl.leadingAnchor.constraint(
            equalTo: titleLabel.trailingAnchor,
            constant: 10
        )
    }
}

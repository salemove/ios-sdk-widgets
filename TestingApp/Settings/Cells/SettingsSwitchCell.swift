import UIKit

final class SettingsSwitchCell: SettingsCell {
    let switcher = UISwitch()

    init(title: String, isOn: Bool) {
        switcher.isOn = isOn
        super.init(title: title)
        layout()
    }

    private func layout() {
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        contentStackView.addArrangedSubview(switcher)
    }
}

import UIKit

final class SettingsSegmentedControlCell: SettingsCell {
    let segmentedControl: UISegmentedControl

    init(title: String, segments: [String], selectedIndex: Int = 0) {
        segmentedControl = UISegmentedControl(items: segments)
        segmentedControl.selectedSegmentIndex = selectedIndex
        super.init(title: title)
        layout()
    }

    private func layout() {
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        contentStackView.addArrangedSubview(segmentedControl)
    }
}

import GliaWidgets
import UIKit

final class EnvironmentSettingsTextCell: SettingsCell {
    let stackView = UIStackView()
    let segmentedControl = UISegmentedControl()
    let customEnvironmentUrlTextField = UITextField()

    var environment: Environment {
        get {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                return .europe
            case 1:
                return .usa
            case 2:
                return .beta
            case 3:
                guard let customUrl = URL(string: customEnvironmentUrlTextField.text ?? "") else {
                    debugPrint("Custom URL is not valid='\(customEnvironmentUrlTextField.text ?? "")'. Fallback to 'beta'.")
                    return .beta
                }
                return .custom(customUrl)
            default:
                debugPrint("Environment is not supported. Fallback to 'beta'.")
                return .beta
            }
        }
        set {
            switch newValue {
            case .europe:
                segmentedControl.selectedSegmentIndex = 0
            case .usa:
                segmentedControl.selectedSegmentIndex = 1
            case .beta:
                segmentedControl.selectedSegmentIndex = 2
            case .custom(let url):
                segmentedControl.selectedSegmentIndex = 3
                customEnvironmentUrlTextField.text = url.absoluteString
            }
            customEnvironmentUrlTextField.isHidden = segmentedControl.selectedSegmentIndex != 3
        }
    }

    init(
        title: String,
        environment: Environment
    ) {
        super.init(title: title)
        segmentedControl.insertSegment(
            withTitle: "EU",
            at: 0,
            animated: false
        )
        segmentedControl.insertSegment(
            withTitle: "US",
            at: 1,
            animated: false
        )
        segmentedControl.insertSegment(
            withTitle: "Beta",
            at: 2,
            animated: false
        )
        segmentedControl.insertSegment(
            withTitle: "Custom",
            at: 3,
            animated: false
        )
        self.environment = environment
        setup()
        layout()
    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 12
        segmentedControl.addTarget(
            self,
            action: #selector(onSegmentedControlChange),
            for: .valueChanged
        )

        customEnvironmentUrlTextField.borderStyle = .roundedRect
        customEnvironmentUrlTextField.autocorrectionType = .no
        customEnvironmentUrlTextField.autocapitalizationType = .none
    }

    private func layout() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(segmentedControl)
        stackView.addArrangedSubview(customEnvironmentUrlTextField)
        stackView.autoPinEdge(.left, to: .right, of: titleLabel, withOffset: 10)
        stackView.autoPinEdgesToSuperviewEdges(
            with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20),
            excludingEdge: .left
        )
    }

    @objc
    private func onSegmentedControlChange(control: UISegmentedControl) {
        customEnvironmentUrlTextField.isHidden = control.selectedSegmentIndex != 3
        (superview as? UITableView)?.reloadData()
    }
}

import UIKit

final class ConnectStatusView: BaseView {
    private let stackView = UIStackView()
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()

    override func setup() {
        super.setup()
        stackView.axis = .vertical
        stackView.spacing = 8

        firstLabel.textAlignment = .center
        secondLabel.textAlignment = .center
    }

    override func defineLayout() {
        super.defineLayout()
        addSubview(stackView)
        stackView.addArrangedSubviews([firstLabel, secondLabel])
        stackView.autoPinEdgesToSuperviewEdges()
    }

    func setStyle(_ style: ConnectStatusStyle) {
        firstLabel.font = style.firstTextFont
        firstLabel.textColor = style.firstTextFontColor
        firstLabel.numberOfLines = 0

        secondLabel.font = style.secondTextFont
        secondLabel.textColor = style.secondTextFontColor
        secondLabel.numberOfLines = 0

        firstLabel.accessibilityHint = style.accessibility.firstTextHint
        secondLabel.accessibilityHint = style.accessibility.secondTextHint
        secondLabel.accessibilityIdentifier = "call_duration_label"
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: firstLabel
        )
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: secondLabel
        )
    }

    func setFirstText(_ text: String?, animated: Bool) {
        setText(text, to: firstLabel, animated: animated)
    }

    func setSecondText(_ text: String?, animated: Bool) {
        setText(text, to: secondLabel, animated: animated)
    }

    private func setText(_ text: String?, to label: UILabel, animated: Bool) {
        label.text = text

        if animated {
            label.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.7,
                options: .curveEaseInOut,
                animations: {
                    label.transform = .identity
                },
                completion: nil
            )
        }
    }
}

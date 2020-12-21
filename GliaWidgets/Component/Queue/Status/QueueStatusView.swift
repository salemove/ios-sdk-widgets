import UIKit

class QueueStatusView: UIView {
    private let stackView = UIStackView()
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setStyle(_ style: QueueStatusStyle) {
        firstLabel.font = style.firstTextFont
        firstLabel.textColor = style.firstTextFontColor
        secondLabel.font = style.secondTextFont
        secondLabel.textColor = style.secondTextFontColor
    }

    func setFirstText(_ text: String?, animated: Bool) {
        setText(text, to: firstLabel, animated: animated)
    }

    func setSecondText(_ text: String?, animated: Bool) {
        setText(text, to: secondLabel, animated: animated)
    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.addArrangedSubviews([firstLabel, secondLabel])

        firstLabel.textAlignment = .center
        secondLabel.textAlignment = .center
    }

    private func layout() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }

    private func setText(_ text: String?, to label: UILabel, animated: Bool) {
        label.text = text
        label.transform = CGAffineTransform(scaleX: 0, y: 0)

        UIView.animate(withDuration: animated ? 0.5 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        label.transform = .identity
                       }, completion: nil)
    }
}

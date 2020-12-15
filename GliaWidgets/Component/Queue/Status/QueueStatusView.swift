import UIKit

class QueueStatusView: UIView {
    private let stackView = UIStackView()
    private let label1 = UILabel()
    private let label2 = UILabel()

    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setStyle(_ style: QueueStatusStyle) {
        label1.font = style.text1Font
        label1.textColor = style.text1FontColor
        label2.font = style.text2Font
        label2.textColor = style.text2FontColor
    }

    func setText1(_ text: String?, animated: Bool) {
        setText(text, to: label1, animated: animated)
    }

    func setText2(_ text: String?, animated: Bool) {
        setText(text, to: label2, animated: animated)
    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.addArrangedSubviews([label1, label2])

        label1.textAlignment = .center
        label2.textAlignment = .center
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
                        self.layoutIfNeeded()
                       }, completion: nil)
    }
}

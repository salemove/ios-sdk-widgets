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

    func setText1(_ text1: String?, text2: String?, animated: Bool) {
        stackView.transform = CGAffineTransform(scaleX: 0, y: 0)
        label1.text = text1
        label2.text = text2

        UIView.animate(withDuration: animated ? 0.5 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        self.stackView.transform = .identity
                        self.stackView.layoutIfNeeded()
                       }, completion: nil)
    }

    func setText2(_ text: String) {
        label2.text = text
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
}

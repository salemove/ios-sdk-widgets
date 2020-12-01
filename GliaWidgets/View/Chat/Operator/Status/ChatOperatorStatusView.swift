import UIKit

class ChatOperatorStatusView: UIView {
    let label1 = UILabel()
    let label2 = UILabel()

    private let stackView = UIStackView()

    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLabel1Text(_ text: String?, animated: Bool) {
        setText(text, to: label1, animated: animated)
    }

    func setLabel2Text(_ text: String?, animated: Bool) {
        setText(text, to: label2, animated: animated)
    }

    private func setText(_ text: String?, to label: UILabel, animated: Bool) {
        UIView.transition(with: label,
                      duration: 0.5,
                       options: .transitionCrossDissolve,
                    animations: {
                        label.text = text
                 }, completion: nil)
    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 8

        label1.textAlignment = .center
        label2.textAlignment = .center
    }

    private func layout() {
        stackView.addArrangedSubviews([label1, label2])

        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }
}

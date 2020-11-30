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

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 8
    }

    private func layout() {
        stackView.addArrangedSubviews([label1, label2])

        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }
}

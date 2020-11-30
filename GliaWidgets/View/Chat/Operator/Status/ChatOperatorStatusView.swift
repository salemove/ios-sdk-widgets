import UIKit

class ChatOperatorStatusView: View {
    let label1 = UILabel()
    let label2 = UILabel()

    private let stackView = UIStackView()

    override init() {
        super.init()
        setup()
        layout()
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

import UIKit

class ChatMessageContentView: UIView {
    init(with content: UIView, insets: UIEdgeInsets) {
        super.init(frame: .zero)
        setup()
        layout(content: content,
               insets: insets)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        layer.cornerRadius = 10
    }

    private func layout(content: UIView, insets: UIEdgeInsets) {
        addSubview(content)
        content.autoPinEdgesToSuperviewEdges(with: insets)
    }
}

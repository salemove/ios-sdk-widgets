import UIKit

class CallView: EngagementView {
    var chatTapped: (() -> Void)?

    private let style: CallStyle
    private let contentView = UIView()

    init(with style: CallStyle) {
        self.style = style
        super.init(with: style)
        setup()
        layout()
    }

    private func setup() {}

    private func layout() {
        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(with: .zero,
                                            excludingEdge: .bottom)

        addSubview(contentView)
        contentView.autoPinEdge(.top, to: .bottom, of: header)
        contentView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)

        backgroundColor = .black
        let chatButton = UIButton(type: .system)
        chatButton.setTitle("Chat", for: .normal)
        chatButton.addTarget(self, action: #selector(chatTap), for: .touchUpInside)
        contentView.addSubview(chatButton)
        chatButton.autoCenterInSuperview()
    }

    @objc private func chatTap() {
        chatTapped?()
    }
}

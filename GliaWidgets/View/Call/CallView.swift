import UIKit

class CallView: EngagementView {
    var chatTapped: (() -> Void)?

    private let style: CallStyle
    private let contentView = UIView()
    private let buttonBar: CallButtonBar

    init(with style: CallStyle) {
        self.style = style
        self.buttonBar = CallButtonBar(with: style.buttonBar)
        super.init(with: style)
        setup()
        layout()
    }

    func setConnectState(_ state: ConnectView.State, animated: Bool) {
        connectView.setState(state, animated: animated)
    }

    private func setup() {
        buttonBar.visibleButtons = [.chat]
    }

    private func layout() {
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(with: .zero,
                                            excludingEdge: .bottom)

        addSubview(contentView)
        contentView.autoPinEdge(.top, to: .bottom, of: header)
        contentView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)

        contentView.addSubview(connectView)
        connectView.autoPinEdge(toSuperviewEdge: .top, withInset: 30)
        connectView.autoAlignAxis(toSuperviewAxis: .vertical)

        contentView.addSubview(buttonBar)
        buttonBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0),
                                               excludingEdge: .top)

        let chatButton = UIButton(type: .system)
        chatButton.setTitle("CHAT", for: .normal)
        chatButton.setTitleColor(.white, for: .normal)
        chatButton.addTarget(self, action: #selector(chatTap), for: .touchUpInside)
        contentView.addSubview(chatButton)
        chatButton.autoPinEdge(toSuperviewSafeArea: .left, withInset: 20)
        chatButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 20)
    }

    @objc private func chatTap() {
        chatTapped?()
    }
}

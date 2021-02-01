import UIKit

class CallView: EngagementView {
    let buttonBar: CallButtonBar
    var chatTapped: (() -> Void)?

    private let style: CallStyle
    private let contentView = UIView()

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

    private func setup() {}

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
        buttonBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0),
                                               excludingEdge: .top)
    }

    @objc private func chatTap() {
        chatTapped?()
    }
}

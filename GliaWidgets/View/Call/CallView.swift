import UIKit

class CallView: EngagementView {
    let infoLabel = UILabel()
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

    private func setup() {
        infoLabel.text = style.infoText
        infoLabel.font = style.infoTextFont
        infoLabel.textColor = style.infoTextColor
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
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
        connectView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        connectView.autoAlignAxis(toSuperviewAxis: .vertical)

        contentView.addSubview(buttonBar)
        buttonBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0),
                                               excludingEdge: .top)

        contentView.addSubview(infoLabel)
        infoLabel.autoPinEdge(.bottom, to: .top, of: buttonBar, withOffset: -38)
        infoLabel.autoMatch(.width, to: .width, of: contentView, withMultiplier: 0.6)
        infoLabel.autoAlignAxis(toSuperviewAxis: .vertical)
    }

    @objc private func chatTap() {
        chatTapped?()
    }
}

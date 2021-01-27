import UIKit

class CallView: EngagementView {
    let operatorImageView = ImageView()
    let operatorNameLabel = UILabel()
    let durationLabel = UILabel()
    var chatTapped: (() -> Void)?

    private let style: CallStyle
    private let contentView = UIView()
    private let callStackView = UIStackView()

    init(with style: CallStyle) {
        self.style = style
        super.init(with: style)
        setup()
        layout()
    }

    func setConnecState(_ state: ConnectView.State, animated: Bool) {
        connectView.setState(state, animated: animated)
    }

    private func setup() {
        operatorNameLabel.font = style.operatorNameFont
        operatorNameLabel.textColor = style.operatorNameColor
        operatorNameLabel.textAlignment = .center

        durationLabel.font = style.durationFont
        durationLabel.textColor = style.durationColor
        durationLabel.textAlignment = .center

        operatorImageView.contentMode = .scaleAspectFill
        operatorImageView.clipsToBounds = true

        callStackView.axis = .vertical
        callStackView.addArrangedSubviews(
            [operatorNameLabel,
             durationLabel,
             operatorImageView]
        )
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

        contentView.addSubview(callStackView)
        callStackView.autoPinEdge(toSuperviewEdge: .left)
        callStackView.autoPinEdge(toSuperviewEdge: .right)
        callStackView.autoAlignAxis(toSuperviewAxis: .horizontal)
        callStackView.setCustomSpacing(8, after: operatorNameLabel)
        callStackView.setCustomSpacing(14, after: durationLabel)

        operatorImageView.autoMatch(.height, to: .width, of: operatorImageView)

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

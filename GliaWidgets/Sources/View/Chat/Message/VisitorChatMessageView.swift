import UIKit

class VisitorChatMessageView: ChatMessageView {
    var status: String? {
        get { return statusLabel.text }
        set { statusLabel.text = newValue }
    }

    private let statusLabel = UILabel()
    private let kInsets = UIEdgeInsets(top: 2, left: 88, bottom: 2, right: 16)

    init(
        with style: VisitorChatMessageStyle,
        environment: Environment
    ) {
        super.init(
            with: style,
            contentAlignment: .right,
            environment: .init(uiScreen: environment.uiScreen)
        )

        setup(style: style)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    private func setup(style: VisitorChatMessageStyle) {
        statusLabel.font = style.statusFont
        statusLabel.textColor = style.statusColor
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: statusLabel
        )
    }

    override func defineLayout() {
        super.defineLayout()
        addSubview(contentViews)
        contentViews.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top)
        contentViews.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right)

        addSubview(statusLabel)
        statusLabel.autoPinEdge(.top, to: .bottom, of: contentViews, withOffset: 2)
        statusLabel.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right)
        statusLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)

        NSLayoutConstraint.autoSetPriority(.required) {
            contentViews.autoPinEdge(toSuperviewEdge: .left, withInset: kInsets.left, relation: .greaterThanOrEqual)
        }
    }
}

import UIKit

class VisitorChatMessageView: ChatMessageView {
    var status: String? {
        get { return statusLabel.text }
        set { statusLabel.text = newValue }
    }

    private let statusLabel = UILabel().makeView()
    private let contentInsets = UIEdgeInsets(top: 2, left: 88, bottom: 2, right: 16)

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
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += contentViews.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top)
        constraints += contentViews.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right)
        constraints += contentViews.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: contentInsets.left)

        addSubview(statusLabel)
        constraints += statusLabel.topAnchor.constraint(equalTo: contentViews.bottomAnchor, constant: 2)
        constraints += statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right)
        constraints += statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)
    }
}

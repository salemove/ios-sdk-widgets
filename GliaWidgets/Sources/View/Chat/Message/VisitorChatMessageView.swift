import UIKit

class VisitorChatMessageView: ChatMessageView {
    var status: String? {
        get { return statusLabel.text }
        set { statusLabel.text = newValue }
    }

    private let statusLabel = UILabel().makeView()
    private let contentInsets = UIEdgeInsets(top: 8, left: 88, bottom: 8, right: 16)

    init(
        with style: Theme.VisitorMessageStyle,
        environment: Environment
    ) {
        super.init(
            with: .init(
                text: style.text,
                background: style.background,
                imageFile: style.imageFile,
                fileDownload: style.fileDownload,
                accessibility: .init(
                    value: style.accessibility.value,
                    isFontScalingEnabled: style.accessibility.isFontScalingEnabled
                )
            ),
            contentAlignment: .right,
            environment: .create(with: environment)
        )

        setup(style: style)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    private func setup(style: Theme.VisitorMessageStyle) {
        statusLabel.font = style.status.font
        statusLabel.textColor = UIColor(hex: style.status.color)
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

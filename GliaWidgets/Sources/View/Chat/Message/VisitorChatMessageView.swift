import UIKit

class VisitorChatMessageView: ChatMessageView {
    var status: String? {
        get { return statusLabel.text }
        set { statusLabel.text = newValue }
    }

    var error: String? {
        get { return errorLabel.text }
        set { errorLabel.text = newValue }
    }

    var messageTapped: (() -> Void)?

    private let statusLabel = UILabel().makeView()
    private let errorLabel = UILabel().makeView()
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

        errorLabel.font = style.error.font
        errorLabel.textColor = UIColor(hex: style.error.color)
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: errorLabel
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

        addSubview(errorLabel)
        constraints += errorLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 0)
        constraints += errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right)
        constraints += errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)

        defineTapGestureRecognizer()
    }

    func defineTapGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapped)
        )
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
    }

    @objc private func tapped() {
        messageTapped?()
    }
}

extension VisitorChatMessageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

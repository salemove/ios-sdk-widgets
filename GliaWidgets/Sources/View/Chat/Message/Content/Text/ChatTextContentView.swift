import UIKit

class ChatTextContentView: BaseView {
    var text: String? {
        get { return textView.text }
        set { setText(newValue) }
    }

    var attributedText: NSMutableAttributedString? {
        get { return textView.attributedText as? NSMutableAttributedString }
        set { return setAttributedText(newValue) }
    }

    var accessibilityProperties: AccessibilityProperties {
        get {
            .init(
                label: contentView.accessibilityLabel,
                value: contentView.accessibilityValue
            )
        }

        set {
            contentView.accessibilityLabel = newValue.label
            contentView.accessibilityValue = newValue.value
            contentView.accessibilityIdentifier = newValue.value
            // Avoid reading empty messages.
            // This is relevant to the case when file attachment is sent without message.
            contentView.isAccessibilityElement = textView.superview != nil
        }
    }

    var linkTapped: ((URL) -> Void)?

    private let textView = UITextView()
    private let style: Theme.ChatTextContentStyle
    private let contentAlignment: ChatMessageContentAlignment
    private let contentView = UIView()
    private let kTextInsets: UIEdgeInsets

    init(
        with style: Theme.ChatTextContentStyle,
        contentAlignment: ChatMessageContentAlignment,
        insets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    ) {
        self.style = style
        self.contentAlignment = contentAlignment
        self.kTextInsets = insets
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.applyBackground(style.background)
    }

    override func setup() {
        super.setup()

        textView.delegate = self
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.dataDetectorTypes = [.link, .phoneNumber]
        textView.linkTextAttributes = [.underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.font = style.text.font
        textView.backgroundColor = .clear
        textView.textColor = UIColor(hex: style.text.color)

        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: textView
        )
    }

    override func defineLayout() {
        super.defineLayout()
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        constraints += contentView.layoutInSuperview(edges: .vertical)

        switch contentAlignment {
        case .left:
            constraints += contentView.layoutInSuperview(edges: .leading)
            constraints += contentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        case .right:
            constraints += contentView.layoutInSuperview(edges: .trailing)
            constraints += contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
        }
    }

    private func setText(_ text: String?) {
        guard let text, !text.isEmpty else {
            textView.removeFromSuperview()
            return
        }

        if textView.superview == nil {
            contentView.addSubview(textView)
            textView.translatesAutoresizingMaskIntoConstraints = false
            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
            constraints += textView.layoutInSuperview(insets: kTextInsets)
        }
        textView.text = text

        textView.accessibilityIdentifier = text
    }

    private func setAttributedText(_ text: NSMutableAttributedString?) {
        guard let text, !text.string.isEmpty else {
            textView.removeFromSuperview()
            return
        }

        if textView.superview == nil {
            contentView.addSubview(textView)
            textView.translatesAutoresizingMaskIntoConstraints = false
            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
            constraints += textView.layoutInSuperview(insets: kTextInsets)
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: style.text.textStyle),
            .foregroundColor: UIColor(hex: style.text.color)
        ]

        text.addAttributes(
            attributes,
            range: NSRange(
                location: 0,
                length: text.length
            )
        )

        textView.attributedText = text
        textView.accessibilityIdentifier = text.string
    }
}

extension ChatTextContentView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        linkTapped?(URL)
        return false
    }
}

extension ChatTextContentView {
    struct AccessibilityProperties {
        var label: String?
        var value: String?
    }
}

#if DEBUG
extension ChatTextContentView {
    static func mock(environment: Environment) -> ChatTextContentView {
        ChatTextContentView(
            with: Theme.ChatTextContentStyle(
                text: .init(
                    color: UIColor.black.hex,
                    font: .systemFont(ofSize: 10),
                    textStyle: .body,
                    accessibility: .init(isFontScalingEnabled: true)
                ),
                background: .init(
                    background: .fill(color: .black),
                    borderColor: UIColor.clear.cgColor,
                    borderWidth: 0,
                    cornerRadius: 8.49
                ),
                accessibility: .init(isFontScalingEnabled: true)
            ),
            contentAlignment: .left,
            insets: .zero
        )
    }
}
#endif

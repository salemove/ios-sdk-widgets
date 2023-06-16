import UIKit

class ChatTextContentView: BaseView {
    var text: String? {
        get { return textView.text }
        set { setText(newValue) }
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
    private let style: ChatTextContentStyle
    private let contentAlignment: ChatMessageContentAlignment
    private let contentView = UIView()
    private let kTextInsets: UIEdgeInsets

    init(
        with style: ChatTextContentStyle,
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

    override func setup() {
        super.setup()
        contentView.backgroundColor = style.backgroundColor
        contentView.layer.cornerRadius = style.cornerRadius

        textView.delegate = self
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.dataDetectorTypes = [.link, .phoneNumber]
        textView.linkTextAttributes = [.underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.font = style.textFont
        textView.backgroundColor = .clear
        textView.textColor = style.textColor
        textView.isAccessibilityElement = false

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
        if text == nil || text?.isEmpty == true {
            textView.removeFromSuperview()
        } else {
            if textView.superview == nil {
                contentView.addSubview(textView)
                textView.translatesAutoresizingMaskIntoConstraints = false
                var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
                constraints += textView.layoutInSuperview(insets: kTextInsets)
            }
            textView.text = text
        }
        textView.accessibilityIdentifier = text
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
            with: ChatTextContentStyle(
                textFont: .systemFont(ofSize: 10),
                textColor: .black,
                backgroundColor: .black,
                accessibility: .unsupported
            ),
            contentAlignment: .left,
            insets: .zero
        )
    }
}
#endif

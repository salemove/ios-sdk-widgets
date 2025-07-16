import UIKit

extension SecureConversations.WelcomeView {
    class MessageTextView: BaseView {
        enum Props: Equatable {
            struct NormalState: Equatable {
                let style: SecureConversations.WelcomeStyle.MessageTextViewStyle
                let text: String
                let activeChanged: Command<Bool>
            }

            struct ActiveState: Equatable {
                let style: SecureConversations.WelcomeStyle.MessageTextViewStyle
                let text: String
                let textChanged: Command<String>
                let activeChanged: Command<Bool>?
            }

            struct DisabledState: Equatable {
                let style: SecureConversations.WelcomeStyle.MessageTextViewStyle
                let text: String
            }

            case normal(NormalState)
            case active(ActiveState)
            case disabled(DisabledState)
        }

        let environment: Environemnt

        var props = Props.normal(.init(style: .initial, text: "", activeChanged: .nop)) {
            didSet {
                renderProps()
            }
        }

        lazy var textView = UITextView().makeView { textView in
            textView.backgroundColor = .clear
            textView.delegate = self
        }

        lazy var placeholderLabel = UILabel().makeView { label in
            label.numberOfLines = 0
        }

        var textViewTopConstraint: NSLayoutConstraint?
        var textViewBottomConstraint: NSLayoutConstraint?
        var textViewLeadingConstraint: NSLayoutConstraint?
        var textViewTrailingConstraint: NSLayoutConstraint?

        init(environment: Environemnt) {
            self.environment = environment
            super.init()
        }

        @available(*, unavailable)
        required init() {
            fatalError("init() has not been implemented")
        }

        override func setup() {
            super.setup()
            addSubview(textView)
            addSubview(placeholderLabel)
        }

        override func defineLayout() {
            super.defineLayout()
            defineTextViewLayout()
            definePlaceholderLabelLayout()
            renderProps()
        }

        func defineTextViewLayout() {
            textViewLeadingConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor)
            textViewTrailingConstraint = textView.trailingAnchor.constraint(equalTo: trailingAnchor)
            textViewTopConstraint = textView.topAnchor.constraint(equalTo: topAnchor)
            textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor)
            NSLayoutConstraint.activate(
                [
                    textViewTopConstraint,
                    textViewBottomConstraint,
                    textViewLeadingConstraint,
                    textViewTrailingConstraint
                ]
                .compactMap { $0 }
            )
            let margin = 16.0
            render(
                edgeInsets: .init(top: margin, left: margin, bottom: margin, right: margin)
            )
        }

        func definePlaceholderLabelLayout() {
            NSLayoutConstraint.activate([
                placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
                placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
                placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor),
                placeholderLabel.bottomAnchor.constraint(lessThanOrEqualTo: textView.bottomAnchor)
            ])
        }

        func render(edgeInsets: UIEdgeInsets) {
            textViewTopConstraint?.constant = edgeInsets.top
            textViewBottomConstraint?.constant = -edgeInsets.bottom
            textViewLeadingConstraint?.constant = edgeInsets.left
            textViewTrailingConstraint?.constant = -edgeInsets.right
        }

        func renderProps() {
            let props = UIKitProps(self.props)
            let style = props.style
            placeholderLabel.textColor = style.placeholderColor
            placeholderLabel.font = style.placeholderFont
            placeholderLabel.text = style.placeholderText

            textView.text = props.text
            textView.font = style.textFont
            textView.textColor = style.textColor
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.isEditable = props.isEnabled
            self.backgroundColor = style.backgroundColor
            self.layer.borderWidth = style.borderWidth
            self.layer.cornerRadius = style.cornerRadius
            self.layer.cornerCurve = .continuous
            self.layer.borderColor = style.borderColor.cgColor
            // Hide placeholder if textfield is active or has non-empty text.
            placeholderLabel.isHidden = !textView.text.isEmpty || textView.isFirstResponder
            renderedActive = props.isActive

            textView.accessibilityIdentifier = "secureConversations_welcome_textView"

            setFontScalingEnabled(style.isFontScalingEnabled, for: textView)
            setFontScalingEnabled(style.isFontScalingEnabled, for: placeholderLabel)
        }

        var renderedActive: Bool = false {
            didSet {
                guard renderedActive != oldValue else { return }
                environment.gcd.mainQueue.async {
                    // Make text view active based on pass value from Props
                    switch (self.renderedActive, self.textView.isFirstResponder) {
                    case (true, true), (false, false):
                        break
                    case (true, false):
                        self.textView.becomeFirstResponder()
                    case (false, true):
                        self.textView.resignFirstResponder()
                    }
                }
            }
        }
    }
}

// MARK: - UIKitProps for MessageTextView
extension SecureConversations.WelcomeView.MessageTextView {
    struct UIKitProps: Equatable {
        struct Style: Equatable {
            var placeholderText: String
            var placeholderFont: UIFont
            var placeholderColor: UIColor
            var textFont: UIFont
            var textColor: UIColor
            var borderColor: UIColor
            var borderWidth: Double
            var cornerRadius: Double
            var backgroundColor: UIColor
            var isFontScalingEnabled: Bool
        }

        let style: Style
        let text: String
        let textChanged: Command<String>?
        let activeChanged: Command<Bool>?
        let isEnabled: Bool
        let isActive: Bool
    }
}

extension SecureConversations.WelcomeView.MessageTextView.UIKitProps {
    init(_ props: SecureConversations.WelcomeView.MessageTextView.Props) {
        switch props {
        case let .normal(normalState):
            self.init(
                style: .init(normalStyle: normalState.style.normalStyle),
                text: normalState.text,
                textChanged: nil,
                activeChanged: normalState.activeChanged,
                isEnabled: true,
                isActive: false
            )
        case let .active(activeState):
            self.init(
                style: .init(activeStyle: activeState.style.activeStyle),
                text: activeState.text,
                textChanged: activeState.textChanged,
                activeChanged: activeState.activeChanged,
                isEnabled: true,
                isActive: true
            )
        case let .disabled(disabledState):
            self.init(
                style: .init(disabledStyle: disabledState.style.disabledStyle),
                text: disabledState.text,
                textChanged: nil,
                activeChanged: nil,
                isEnabled: false,
                isActive: false
            )
        }
    }
}

extension SecureConversations.WelcomeView.MessageTextView.UIKitProps.Style {
    init(activeStyle: SecureConversations.WelcomeStyle.MessageTextViewActiveStyle) {
        self.init(
            placeholderText: activeStyle.placeholderText,
            placeholderFont: activeStyle.placeholderFont,
            placeholderColor: activeStyle.placeholderColor,
            textFont: activeStyle.textFont,
            textColor: activeStyle.textColor,
            borderColor: activeStyle.borderColor,
            borderWidth: activeStyle.borderWidth,
            cornerRadius: activeStyle.cornerRadius,
            backgroundColor: activeStyle.backgroundColor,
            isFontScalingEnabled: activeStyle.accessibility.isFontScalingEnabled
        )
    }

    init(disabledStyle: SecureConversations.WelcomeStyle.MessageTextViewDisabledStyle) {
        self.init(
            placeholderText: disabledStyle.placeholderText,
            placeholderFont: disabledStyle.placeholderFont,
            placeholderColor: disabledStyle.placeholderColor,
            textFont: disabledStyle.textFont,
            textColor: disabledStyle.textColor,
            borderColor: disabledStyle.borderColor,
            borderWidth: disabledStyle.borderWidth,
            cornerRadius: disabledStyle.cornerRadius,
            backgroundColor: disabledStyle.backgroundColor,
            isFontScalingEnabled: disabledStyle.accessibility.isFontScalingEnabled
        )
    }

    init(normalStyle: SecureConversations.WelcomeStyle.MessageTextViewNormalStyle) {
        self.init(
            placeholderText: normalStyle.placeholderText,
            placeholderFont: normalStyle.placeholderFont,
            placeholderColor: normalStyle.placeholderColor,
            textFont: normalStyle.textFont,
            textColor: normalStyle.textColor,
            borderColor: normalStyle.borderColor,
            borderWidth: normalStyle.borderWidth,
            cornerRadius: normalStyle.cornerRadius,
            backgroundColor: normalStyle.backgroundColor,
            isFontScalingEnabled: normalStyle.accessibility.isFontScalingEnabled
        )
    }
}

// MARK: - MessageTextView as UITextViewDelegate
extension SecureConversations.WelcomeView.MessageTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        UIKitProps(props).textChanged?(textView.text)
    }

    public func textViewDidBeginEditing(_: UITextView) {
        UIKitProps(props).activeChanged?(true)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        UIKitProps(props).activeChanged?(false)
    }
}

private extension SecureConversations.WelcomeStyle.MessageTextViewStyle {
    static let initial = SecureConversations.WelcomeStyle.MessageTextViewStyle(
        normalStyle: .init(
            placeholderText: "",
            placeholderFont: .systemFont(ofSize: 12),
            placeholderColor: .black,
            textFont: .systemFont(ofSize: 12),
            textFontStyle: .caption1,
            textColor: .black,
            borderColor: .black,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: .black,
            accessibility: .init(isFontScalingEnabled: true)
        ),
        disabledStyle: .init(
            placeholderText: "",
            placeholderFont: .systemFont(ofSize: 12),
            placeholderColor: .black,
            textFont: .systemFont(ofSize: 12),
            textFontStyle: .caption1,
            textColor: .black,
            borderColor: .black,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: .lightGray,
            accessibility: .init(isFontScalingEnabled: true)
        ),
        activeStyle: .init(
            placeholderText: "",
            placeholderFont: .systemFont(ofSize: 12),
            placeholderColor: .black,
            textFont: .systemFont(ofSize: 12),
            textFontStyle: .caption1,
            textColor: .black,
            borderColor: .black,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: .blue,
            accessibility: .init(isFontScalingEnabled: true)
        )
    )
}

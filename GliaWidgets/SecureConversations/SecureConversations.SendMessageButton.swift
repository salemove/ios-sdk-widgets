import UIKit

extension SecureConversations {
    class SendMessageButton: UIControl {
        var props: Props = .normal(
            .init(
                title: "Title",
                titleFont: .systemFont(ofSize: 15),
                foregroundColor: .white,
                backgroundColor: .black,
                borderColor: .red,
                borderWidth: 3,
                cornerRadius: 8,
                activityIndicatorColor: .green,
                isActivityIndicatorShown: false,
                isFontScalingEnabled: false,
                accessibilityLabel: "",
                accessibilityHint: ""
            )
        ) {
            didSet {
                renderProps()
            }
        }

        lazy var messageTitleLabel = UILabel().makeView()
        lazy var activityIndicator: ActivityIndicatorView = {
            let indicator = ActivityIndicatorView()
            indicator.isHidden = true
            return indicator
        }()
        lazy var messageTitleStackView = UIStackView(arrangedSubviews: [
            activityIndicator,
            messageTitleLabel
        ]).makeView { stackView in
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.spacing = 11
            stackView.isUserInteractionEnabled = false
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
            renderProps()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setup() {
            addSubview(messageTitleStackView)
            NSLayoutConstraint.activate([
                messageTitleStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                messageTitleStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }

        func renderProps() {
            let props = UIKitProps(props)
            messageTitleLabel.text = props.title
            messageTitleLabel.font = props.titleFont
            messageTitleLabel.textColor = props.foregroundColor
            backgroundColor = props.backgroundColor
            layer.borderWidth = props.borderWidth
            layer.borderColor = props.borderColor.cgColor
            layer.cornerRadius = props.cornerRadius
            activityIndicator.color = props.activityIndicatorColor
            renderedIsIndicatorShown = props.isActivityIndicatorShown
            accessibilityTraits = .button
            accessibilityLabel = props.accessibilityLabel
            accessibilityHint = props.accessibilityHint
            isAccessibilityElement = true
            accessibilityIdentifier = "secureConversations_welcomeSend_button"
        }

        var renderedIsIndicatorShown: Bool = false {
            didSet {
                guard renderedIsIndicatorShown != oldValue else { return }
                activityIndicator.isHidden = !renderedIsIndicatorShown

                if renderedIsIndicatorShown {
                    activityIndicator.startAnimating()
                } else {
                    activityIndicator.stopAnimating()
                }
            }
        }
    }
}

extension SecureConversations.SendMessageButton {
    enum Props: Equatable {
        case normal(NormalState)
        case disabled(DisabledState)
    }
}

extension SecureConversations.SendMessageButton.Props {
    struct NormalState: Equatable {
        let title: String
        let titleFont: UIFont
        let foregroundColor: UIColor
        let backgroundColor: UIColor
        let borderColor: UIColor
        let borderWidth: Double
        let cornerRadius: Double
        let activityIndicatorColor: UIColor
        let isActivityIndicatorShown: Bool
        let isFontScalingEnabled: Bool
        let accessibilityLabel: String
        let accessibilityHint: String
    }

    struct DisabledState: Equatable {
        let title: String
        let titleFont: UIFont
        let foregroundColor: UIColor
        let backgroundColor: UIColor
        let borderColor: UIColor
        let borderWidth: Double
        let cornerRadius: Double
        let activityIndicatorColor: UIColor
        let isActivityIndicatorShown: Bool
        let isFontScalingEnabled: Bool
        let accessibilityLabel: String
        let accessibilityHint: String
    }
}

extension SecureConversations.SendMessageButton {
    struct UIKitProps: Equatable {
        let title: String
        let titleFont: UIFont
        let foregroundColor: UIColor
        let backgroundColor: UIColor
        let borderColor: UIColor
        let borderWidth: Double
        let cornerRadius: Double
        let activityIndicatorColor: UIColor
        let isActivityIndicatorShown: Bool
        let isEnabled: Bool
        let isFontScalingEnabled: Bool
        let accessibilityLabel: String
        let accessibilityHint: String

        init(_ props: Props) {
            switch props {
            case let .normal(state):
                self.title = state.title
                self.titleFont = state.titleFont
                self.foregroundColor = state.foregroundColor
                self.backgroundColor = state.backgroundColor
                self.borderColor = state.borderColor
                self.borderWidth = state.borderWidth
                self.cornerRadius = state.cornerRadius
                self.activityIndicatorColor = state.activityIndicatorColor
                self.isActivityIndicatorShown = state.isActivityIndicatorShown
                self.isEnabled = true
                self.isFontScalingEnabled = state.isFontScalingEnabled
                self.accessibilityLabel = state.accessibilityLabel
                self.accessibilityHint = state.accessibilityHint
            case let .disabled(state):
                self.title = state.title
                self.titleFont = state.titleFont
                self.foregroundColor = state.foregroundColor
                self.backgroundColor = state.backgroundColor
                self.borderColor = state.borderColor
                self.borderWidth = state.borderWidth
                self.cornerRadius = state.cornerRadius
                self.activityIndicatorColor = state.activityIndicatorColor
                self.isActivityIndicatorShown = state.isActivityIndicatorShown
                self.isEnabled = false
                self.isFontScalingEnabled = state.isFontScalingEnabled
                self.accessibilityLabel = state.accessibilityLabel
                self.accessibilityHint = state.accessibilityHint
            }
        }
    }
}

extension SecureConversations.SendMessageButton.Props {
    init(enabledStyle: SecureConversations.WelcomeStyle.SendButtonEnabledStyle) {
        self = .normal(
            .init(
                title: enabledStyle.title,
                titleFont: enabledStyle.font,
                foregroundColor: enabledStyle.textColor,
                backgroundColor: enabledStyle.backgroundColor,
                borderColor: enabledStyle.borderColor,
                borderWidth: enabledStyle.borderWidth,
                cornerRadius: enabledStyle.cornerRadius,
                activityIndicatorColor: .clear,
                isActivityIndicatorShown: false,
                isFontScalingEnabled: enabledStyle.accessibility.isFontScalingEnabled,
                accessibilityLabel: enabledStyle.accessibility.label,
                accessibilityHint: enabledStyle.accessibility.hint
            )
        )
    }

    init(disabledStyle: SecureConversations.WelcomeStyle.SendButtonDisabledStyle) {
        self = .disabled(
            .init(
                title: disabledStyle.title,
                titleFont: disabledStyle.font,
                foregroundColor: disabledStyle.textColor,
                backgroundColor: disabledStyle.backgroundColor,
                borderColor: disabledStyle.borderColor,
                borderWidth: disabledStyle.borderWidth,
                cornerRadius: disabledStyle.cornerRadius,
                activityIndicatorColor: .clear,
                isActivityIndicatorShown: false,
                isFontScalingEnabled: disabledStyle.accessibility.isFontScalingEnabled,
                accessibilityLabel: disabledStyle.accessibility.label,
                accessibilityHint: disabledStyle.accessibility.hint
            )
        )
    }

    init(loadingStyle: SecureConversations.WelcomeStyle.SendButtonLoadingStyle) {
        self = .disabled(
            .init(
                title: loadingStyle.title,
                titleFont: loadingStyle.font,
                foregroundColor: loadingStyle.textColor,
                backgroundColor: loadingStyle.backgroundColor,
                borderColor: loadingStyle.borderColor,
                borderWidth: loadingStyle.borderWidth,
                cornerRadius: loadingStyle.cornerRadius,
                activityIndicatorColor: loadingStyle.activityIndicatorColor,
                isActivityIndicatorShown: true,
                isFontScalingEnabled: loadingStyle.accessibility.isFontScalingEnabled,
                accessibilityLabel: loadingStyle.accessibility.label,
                accessibilityHint: loadingStyle.accessibility.hint
            )
        )
    }
}

extension SecureConversations.WelcomeView.Props.SendMessageButton {
    struct UIKitProps: Equatable {
        var tap: Cmd?
        var isLoading: Bool
        var isEnabled: Bool

        init(_ state: SecureConversations.WelcomeView.Props.SendMessageButton) {
            switch state {
            case let .active(action):
                tap = action
                isEnabled = true
                isLoading = false
            case .disabled:
                tap = nil
                isEnabled = false
                isLoading = false
            case .loading:
                tap = nil
                isEnabled = false
                isLoading = true
            }
        }
    }
}

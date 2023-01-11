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
                isActivityIndicatorShown: false
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
            }
        }
    }
}

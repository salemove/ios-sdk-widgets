import UIKit

extension CallVisualizer {
    final class ScreenSharingView: BaseView {

        // MARK: - Props

        struct Props: Equatable {
            let style: ScreenSharingViewStyle
            let header: Header.Props
            let endScreenSharing: ActionButton.Props

            init(
                style: ScreenSharingViewStyle,
                header: Header.Props,
                endScreenSharing: ActionButton.Props
            ) {
                self.style = style
                self.header = header
                self.endScreenSharing = endScreenSharing
            }
        }

        // MARK: - Properties

        private lazy var header = Header(props: props.header)
            .make { header in
                header.endScreenShareButton.isHidden = true
                header.closeButton.isHidden = true
                header.endButton.isHidden = true
            }
        private lazy var messageLabel = UILabel().make {
            $0.font = props.style.messageTextFont
            $0.textColor = props.style.messageTextColor
            $0.text = props.style.messageText
            $0.adjustsFontSizeToFitWidth = true
            $0.numberOfLines = 2
            $0.textAlignment = .center
            $0.accessibilityIdentifier = "end_screen_sharing_message"
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        private lazy var endScreenSharingButton = ActionButton(props: props.endScreenSharing).make {
            $0.setImage(props.style.buttonIcon, for: .normal)
            $0.tintColor = props.style.buttonStyle.titleColor
            $0.titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
            $0.accessibilityIdentifier = "end_screen_sharing_button"
            $0.accessibilityLabel = Localization.ScreenSharing.VisitorScreen.end
            $0.accessibilityHint = Localization.ScreenSharing.VisitorScreen.End.Accessibility.hint
        }
        private lazy var contentStackView = UIStackView.make(
            .vertical,
            spacing: 16
        )(
            messageLabel,
            endScreenSharingButton
        )

        var props: Props {
            didSet {
                renderProps()
            }
        }

        // MARK: - Initialization

        init(props: Props) {
            self.props = props
            super.init()
        }

        required init() {
            fatalError("init() has not been implemented")
        }

        // MARK: - Overrides

        override func setup() {
            super.setup()

            addSubview(header)
            header.translatesAutoresizingMaskIntoConstraints = false
            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
            constraints += header.layoutInSuperview(edges: .horizontal)

            addSubview(contentStackView)
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
            constraints += contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
            constraints += contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
            constraints += contentStackView.layoutIn(layoutMarginsGuide, edges: .horizontal, insets: .init(top: 0, left: 42, bottom: 0, right: 42))

            constraints += endScreenSharingButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)

            if let imageView = endScreenSharingButton.imageView {
                constraints += imageView.widthAnchor.constraint(equalToConstant: 24)
            }

            setFontScalingEnabled(
                props.style.accessibility.isFontScalingEnabled,
                for: messageLabel
            )
            setFontScalingEnabled(
                props.style.buttonStyle.accessibility.isFontScalingEnabled,
                for: endScreenSharingButton
            )
        }

        override func layoutSubviews() {
            switch props.style.backgroundColor {
            case .fill(let color):
                backgroundColor = color
            case .gradient(let colors):
                makeGradientBackground(colors: colors)
            }
        }
    }
}

// MARK: - Private

private extension CallVisualizer.ScreenSharingView {
    func renderProps() {
        header.props = props.header
        endScreenSharingButton.props = props.endScreenSharing
    }
}

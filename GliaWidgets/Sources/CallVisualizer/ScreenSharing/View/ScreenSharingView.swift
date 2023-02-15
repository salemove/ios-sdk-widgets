import UIKit

extension CallVisualizer {
    final class ScreenSharingView: BaseView {

        // MARK: - Props

        struct Props: Equatable {
            let style: ScreenSharingViewStyle
            let headerProps: Header.Props
            let endScreenSharingButtonProps: ActionButton.Props

            init(
                style: ScreenSharingViewStyle,
                headerProps: Header.Props,
                endScreenSharingButtonProps: ActionButton.Props
            ) {
                self.style = style
                self.endScreenSharingButtonProps = endScreenSharingButtonProps
                self.headerProps = headerProps
            }
        }

        // MARK: - Properties

        private lazy var header = Header(
            props: props.headerProps
        )
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
        }
        private lazy var endScreenSharingButton = ActionButton(props: props.endScreenSharingButtonProps).make {
            $0.setImage(props.style.buttonIcon, for: .normal)
            $0.tintColor = props.style.buttonStyle.titleColor
            $0.titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
            $0.accessibilityIdentifier = "end_screen_sharing_button"
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

            backgroundColor = .white

            addSubview(header)
            header.autoPinEdge(toSuperviewEdge: .left)
            header.autoPinEdge(toSuperviewEdge: .right)

            addSubview(contentStackView)
            contentStackView.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: 0)
            contentStackView.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: 0)
            contentStackView.autoPinEdge(toSuperviewMargin: .leading, withInset: 42)
            contentStackView.autoPinEdge(toSuperviewMargin: .trailing, withInset: 42)

            endScreenSharingButton.autoSetDimension(.height, toSize: 40)
        }
    }
}

// MARK: - Private

private extension CallVisualizer.ScreenSharingView {
    func renderProps() {
        setFontScalingEnabled(
            props.style.accessibility.isFontScalingEnabled,
            for: messageLabel
        )

        header.props = props.headerProps
        endScreenSharingButton.props = props.endScreenSharingButtonProps

        switch props.style.backgroundColor {
        case .fill(let color):
            backgroundColor = color
        case .gradient(let colors):
            makeGradientBackground(colors: colors)
        }
    }
}

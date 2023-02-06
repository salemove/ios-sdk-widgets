import UIKit

extension CallVisualizer {
    final class ScreenSharingView: BaseView {

        // MARK: - Props

        struct Props: Equatable {
            let style: ScreenSharingViewStyle
            let endScreenSharing: Cmd
            let back: Cmd

            init(
                style: ScreenSharingViewStyle = Theme().screenSharing,
                endScreenSharing: Cmd = .nop,
                back: Cmd = .nop
            ) {
                self.style = style
                self.endScreenSharing = endScreenSharing
                self.back = back
            }
        }

        // MARK: - Properties

        private lazy var header = Header(with: props.style.header).make { header in
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
        private lazy var endScreenSharingButton = ActionButton(with: props.style.buttonStyle).make {
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

        var props: Props = Props() {
            didSet {
                renderProps()
            }
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

        header.title = props.style.title
        header.backButton.tap = props.back.execute
        endScreenSharingButton.tap = props.endScreenSharing.execute
    }
}

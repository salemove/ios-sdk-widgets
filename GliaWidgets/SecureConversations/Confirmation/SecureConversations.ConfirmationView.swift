import Foundation
import UIKit

extension SecureConversations {
    final class ConfirmationView: BaseView {
        static let sideMargin = 24.0
        static let portraitConfirmationImageSize = 144.0
        static let landscapeConfirmationImageSize = 90.0

        struct Props: Equatable {
            let style: ConfirmationStyle
            let header: Header.Props
            let checkMessageButtonTap: Cmd
        }

        private let header: Header

        var topRootStackViewConstraint: NSLayoutConstraint?
        var confirmationImageViewWidthConstraints: NSLayoutConstraint?
        var confirmationImageViewHeightConstraints: NSLayoutConstraint?

        lazy var rootStackView = UIStackView.make(
            .vertical,
            spacing: 0,
            distribution: .fill,
            alignment: .center
        )(
            confirmationImageView,
            titleLabel,
            subtitleLabel,
            spacer,
            checkMessagesButton
        )

        let confirmationImageView = UIImageView().makeView { imageView in
            imageView.image = Asset.mcConfirmation.image.withRenderingMode(.alwaysTemplate)
        }
        let titleLabel = UILabel().makeView { label in
            label.numberOfLines = 0
            label.textAlignment = .center
        }

        let subtitleLabel = UILabel().makeView { label in
            label.numberOfLines = 0
            label.textAlignment = .center
        }

        // Flexible space to accommodate the check messages button
        // at the bottom of the view.
        let spacer = UIView()

        lazy var checkMessagesButton = UIButton(type: .custom).makeView { button in
            button.addTarget(
                self,
                action: #selector(handleCheckMessagesButtonTap),
                for: .touchUpInside
            )

            button.layer.cornerRadius = 4
        }

        var props: Props {
            didSet {
                renderProps()
            }
        }

        init(props: Props) {
            self.header = Header(
                props: props.header
            )
            self.props = props
            super.init()
        }

        @available(*, unavailable)
        required init() {
            fatalError("init() has not been implemented")
        }

        override func defineLayout() {
            super.defineLayout()
            defineHeaderLayout()
            defineRootStackViewLayout()
            defineConfirmationImageViewLayout()
            defineTitleLabelLayout()
            defineSubtitleLabelLayout()
            defineSpacerLayout()
            defineCheckMessagesButtonLayout()
            renderProps()
        }

        override func setup() {
            super.setup()
            addSubview(rootStackView)
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            changeConfirmationImageViewDimensions()
        }

        private func changeConfirmationImageViewDimensions() {
            // The portrait factor is the factor between the space from the header
            // to the beginning of the stack view versus the height of the screen
            // in the Figma design. The landscape factor was calculated through trial
            // and error to avoid a bug where the image was so big that it would hide
            // the text below it.
            let factor = currentOrientation.isPortrait ? 0.2783 : 0.075
            topRootStackViewConstraint?.constant = self.rootStackView.frame.height * factor

            let imageSize = currentOrientation.isPortrait ?
                Self.portraitConfirmationImageSize :
                Self.landscapeConfirmationImageSize

            confirmationImageViewWidthConstraints?.constant = imageSize
            confirmationImageViewHeightConstraints?.constant = imageSize
        }

        private func defineHeaderLayout() {
            addSubview(header)
            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
            constraints += header.layoutInSuperview(edges: .horizontal)
            constraints += header.layoutInSuperview(edges: .top)
        }

        func defineRootStackViewLayout() {
            topRootStackViewConstraint = rootStackView.topAnchor.constraint(equalTo: header.bottomAnchor)
            NSLayoutConstraint.activate([
                rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.sideMargin),
                rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.sideMargin),
                topRootStackViewConstraint,
                rootStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Self.sideMargin)
            ].compactMap { $0 })
        }

        private func defineConfirmationImageViewLayout() {
            confirmationImageViewWidthConstraints = confirmationImageView.widthAnchor.constraint(
                equalToConstant: Self.portraitConfirmationImageSize
            )
            confirmationImageViewHeightConstraints = confirmationImageView.heightAnchor.constraint(
                equalToConstant: Self.portraitConfirmationImageSize
            )

            NSLayoutConstraint.activate([
                confirmationImageView.topAnchor.constraint(equalTo: rootStackView.topAnchor),
                confirmationImageViewWidthConstraints,
                confirmationImageViewHeightConstraints
            ].compactMap { $0 })

            rootStackView.setCustomSpacing(32, after: confirmationImageView)
        }

        private func defineTitleLabelLayout() {
            rootStackView.setCustomSpacing(16, after: titleLabel)
        }

        private func defineSubtitleLabelLayout() {
            rootStackView.setCustomSpacing(0, after: subtitleLabel)
        }

        private func defineSpacerLayout() {
            NSLayoutConstraint.activate([
                spacer.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
            ])
        }
        private func defineCheckMessagesButtonLayout() {
            NSLayoutConstraint.activate([
                checkMessagesButton.widthAnchor.constraint(
                    equalTo: rootStackView.widthAnchor
                ),
                checkMessagesButton.heightAnchor.constraint(equalToConstant: 48)
            ])
        }
        @objc func handleCheckMessagesButtonTap() {
            props.checkMessageButtonTap()
        }

        private func renderProps() {
            header.props = props.header
            header.showCloseButton()

            confirmationImageView.tintColor = props.style.confirmationImageTint
            titleLabel.text = props.style.titleStyle.text
            titleLabel.textColor = props.style.titleStyle.color
            titleLabel.font = props.style.titleStyle.font
            setFontScalingEnabled(
                props.style.titleStyle.accessibility.isFontScalingEnabled,
                for: titleLabel
            )

            subtitleLabel.text = props.style.subtitleStyle.text
            subtitleLabel.textColor = props.style.subtitleStyle.color
            subtitleLabel.font = props.style.subtitleStyle.font
            setFontScalingEnabled(
                props.style.subtitleStyle.accessibility.isFontScalingEnabled,
                for: subtitleLabel
            )

            checkMessagesButton.setTitle(props.style.checkMessagesButtonStyle.title, for: .normal)
            checkMessagesButton.setTitleColor(props.style.checkMessagesButtonStyle.textColor, for: .normal)
            checkMessagesButton.backgroundColor = props.style.checkMessagesButtonStyle.backgroundColor
            checkMessagesButton.accessibilityTraits = .button
            checkMessagesButton.accessibilityIdentifier = "secureConversations_confirmationCheckMessages_button"
            checkMessagesButton.accessibilityLabel = props.style.checkMessagesButtonStyle.accessibility.label
            checkMessagesButton.accessibilityHint = props.style.checkMessagesButtonStyle.accessibility.hint
            setFontScalingEnabled(
                props.style.checkMessagesButtonStyle.accessibility.isFontScalingEnabled,
                for: checkMessagesButton
            )

            backgroundColor = props.style.backgroundColor
        }
    }
}

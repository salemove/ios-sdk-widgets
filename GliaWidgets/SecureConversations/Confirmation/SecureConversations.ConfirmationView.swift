import Foundation
import UIKit

extension SecureConversations {
    final class ConfirmationView: View {
        static let sideMargin = 24.0
        static let confirmationImageSize = 144.0

        struct Props: Equatable {
            let style: ConfirmationStyle
            let backButtonTap: Cmd
            let closeButtonTap: Cmd
            let checkMessageButtonTap: Cmd
        }

        private let header: Header

        var topRootStackViewConstraint: NSLayoutConstraint?

        lazy var rootStackView = UIStackView.make(
            .vertical,
            spacing: 0,
            distribution: .fillProportionally,
            alignment: .center
        )(
            confirmationImageView,
            titleLabel,
            subtitleLabel,
            spacer,
            checkMessagesButton
        )

        let confirmationImageView = UIImageView().makeView { imageView in
            imageView.image = Asset.mcConfirmation.image
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
            self.header = Header(with: props.style.header)
            self.props = props
            super.init()
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
        }

        override func setup() {
            super.setup()
            renderProps()
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            // The factor between the space from the header to the beginning of the stack view
            // versus the height of the screen in the Figma design.
            topRootStackViewConstraint?.constant = self.rootStackView.frame.height * 0.2783
        }
        private func defineHeaderLayout() {
            addSubview(header)
            header.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                header.leadingAnchor.constraint(equalTo: leadingAnchor),
                header.trailingAnchor.constraint(equalTo: trailingAnchor),
                header.topAnchor.constraint(equalTo: topAnchor)
            ])
        }

        func defineRootStackViewLayout() {
            addSubview(rootStackView)
            topRootStackViewConstraint = rootStackView.topAnchor.constraint(equalTo: header.bottomAnchor)
            NSLayoutConstraint.activate([
                rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.sideMargin),
                rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.sideMargin),
                topRootStackViewConstraint,
                rootStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Self.sideMargin)
            ].compactMap { $0 })
        }

        private func defineConfirmationImageViewLayout() {
            NSLayoutConstraint.activate([
                confirmationImageView.topAnchor.constraint(equalTo: rootStackView.topAnchor),
                confirmationImageView.widthAnchor.constraint(equalToConstant: Self.confirmationImageSize),
                confirmationImageView.heightAnchor.constraint(equalToConstant: Self.confirmationImageSize)
            ])
            rootStackView.setCustomSpacing(32, after: confirmationImageView)
        }

        private func defineTitleLabelLayout() {
            NSLayoutConstraint.activate([
                titleLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
            rootStackView.setCustomSpacing(16, after: titleLabel)
        }

        private func defineSubtitleLabelLayout() {
            NSLayoutConstraint.activate([
                subtitleLabel.heightAnchor.constraint(equalToConstant: 40)
            ])
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
            header.title = props.style.headerTitle
            header.backButton.tap = props.backButtonTap.execute
            header.closeButton.tap = props.backButtonTap.execute
            header.showCloseButton()

            titleLabel.text = props.style.titleStyle.text
            titleLabel.textColor = props.style.titleStyle.color
            titleLabel.font = props.style.titleStyle.font

            subtitleLabel.text = props.style.subtitleStyle.text
            subtitleLabel.textColor = props.style.subtitleStyle.color
            subtitleLabel.font = props.style.subtitleStyle.font

            checkMessagesButton.setTitle(props.style.checkMessagesButtonStyle.title, for: .normal)
            checkMessagesButton.setTitleColor(props.style.checkMessagesButtonStyle.textColor, for: .normal)
            checkMessagesButton.backgroundColor = props.style.checkMessagesButtonStyle.backgroundColor

            backgroundColor = props.style.backgroundColor
        }
    }
}

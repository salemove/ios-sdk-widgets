import Foundation
import UIKit

extension SecureConversations {
    final class WelcomeView: View {
        static let sideMargin = 24.0
        static let filePickerButtonSize = 44.0

        struct Props: Equatable {
            let style: SecureConversations.WelcomeStyle
            let backButtonTap: Cmd
            let closeButtonTap: Cmd
            let checkMessageButtonTap: Cmd
            let filePickerButtonTap: Cmd?
            let sendMessageButtonTap: Cmd
            let messageTextViewProps: MessageTextView.Props
        }

        var props: Props {
            didSet {
               renderProps()
            }
        }

        let header: Header
        let titleIconView = UIImageView().makeView { imageView in
            imageView.image = Asset.mcEnvelope.image
        }

        let titleLabel = UILabel().makeView { label in
            label.numberOfLines = 0
        }

        let subtitleLabel = UILabel().makeView { label in
            label.numberOfLines = 0
        }

        lazy var checkMessagesButton = UIButton(type: .custom).makeView { button in
            button.addTarget(
                self,
                action: #selector(handleCheckMessagesButtonTap),
                for: .touchUpInside
            )
        }

        let messageTitleLabel = UILabel().makeView()

        lazy var filePickerButton = UIButton().makeView { button in
            button.setImage(Asset.mcPickMedia.image, for: .normal)
            button.addTarget(
                self,
                action: #selector(handleFilePickerButtonTap),
                for: .touchUpInside
            )
        }

        let messageTextView = MessageTextView().makeView()

        lazy var sendMessageButton = UIButton().makeView { button in
            button.addTarget(
                self,
                action: #selector(handleSendMessageButtonTap),
                for: .touchUpInside
            )
        }

        lazy var scrollView = UIScrollView().makeView { scrollView in
            scrollView.keyboardDismissMode = .onDrag
            scrollView.addGestureRecognizer(scrollViewTapRecognizer)
        }

        lazy var rootStackView = UIStackView(
            arrangedSubviews: [
                titleIconView,
                titleLabel,
                subtitleLabel,
                checkMessagesButton,
                messageTitleStackView,
                messageTextView,
                sendMessageButton
            ]
        ).makeView { stackView in
            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = .init(top: 0, left: Self.sideMargin, bottom: 0, right: Self.sideMargin)
        }

        lazy var messageTitleStackView = UIStackView(arrangedSubviews: [messageTitleLabel, filePickerButton])
            .makeView { stackView in
                stackView.axis = .horizontal
            }

        var scrollViewBottomConstraint: NSLayoutConstraint?

        lazy var scrollViewTapRecognizer: UITapGestureRecognizer = {
            let recognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(handleContentViewTap)
            )
            recognizer.cancelsTouchesInView = false
            return recognizer
        }()

        // Since some of the reusable views require style
        // to be passed during initializtion, we have to
        // provide `Props` also during initializtion, because
        // it is single source of data (including styles)
        // for the data-driven view.
        init(props: Props) {
            self.header = Header(with: props.style.header)
            self.props = props
            super.init()
        }

        override func defineLayout() {
            super.defineLayout()
            defineHeaderLayout()
            defineScrollViewLayout()
            defineRootStackViewLayout()
            defineTitleIconLayout()
            defineTitleLabelLayout()
            defineSubtitleLabelLayout()
            defineCheckMessagesButtonLayout()
            defineMessageTitleStackViewLayout()
            defineMessageTitleLabelLayout()
            defineFilePickerButtonLayout()
            defineMessageTextViewLayout()
            defineSendMessageButtonLayout()
        }

        override func setup() {
            super.setup()
            subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
            subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
            renderProps()
        }

        func defineHeaderLayout() {
            addSubview(header)
            header.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                header.leadingAnchor.constraint(equalTo: leadingAnchor),
                header.trailingAnchor.constraint(equalTo: trailingAnchor),
                header.topAnchor.constraint(equalTo: topAnchor)
            ])
        }

        func defineScrollViewLayout() {
            addSubview(scrollView)
            scrollViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            NSLayoutConstraint.activate(
                [
                    scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                    scrollView.topAnchor.constraint(equalTo: header.safeAreaLayoutGuide.bottomAnchor),
                    scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                    scrollViewBottomConstraint
                ].compactMap({ $0 })
            )
        }

        func defineRootStackViewLayout() {
            scrollView.addSubview(rootStackView)
            NSLayoutConstraint.activate([
                rootStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                rootStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                rootStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 42),
                rootStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
            ])
        }

        func defineTitleIconLayout() {
            NSLayoutConstraint.activate([
                titleIconView.widthAnchor.constraint(equalToConstant: 24),
                titleIconView.heightAnchor.constraint(equalToConstant: 24)
            ])
            rootStackView.setCustomSpacing(10, after: titleIconView)
        }

        func defineTitleLabelLayout() {
            NSLayoutConstraint.activate([
                titleLabel.trailingAnchor.constraint(
                    lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor,
                    constant: -Self.sideMargin
                )
            ])
            rootStackView.setCustomSpacing(16, after: titleLabel)

        }

        func defineSubtitleLabelLayout() {
            NSLayoutConstraint.activate([
                subtitleLabel.trailingAnchor.constraint(
                    lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor,
                    constant: -Self.sideMargin
                )
            ])
            rootStackView.setCustomSpacing(16, after: subtitleLabel)

        }

        func defineCheckMessagesButtonLayout() {
            rootStackView.setCustomSpacing(56, after: checkMessagesButton)
        }

        func defineMessageTitleStackViewLayout() {
            rootStackView.setCustomSpacing(5, after: messageTitleStackView)
        }

        func defineMessageTitleLabelLayout() {
            NSLayoutConstraint.activate([
                messageTitleLabel.trailingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.trailingAnchor,
                    constant: -Self.filePickerButtonSize - Self.sideMargin
                )
            ])
        }

        func defineFilePickerButtonLayout() {
            NSLayoutConstraint.activate([
                filePickerButton.widthAnchor.constraint(equalToConstant: Self.filePickerButtonSize),
                filePickerButton.heightAnchor.constraint(equalToConstant: Self.filePickerButtonSize)
            ])
        }

        func defineMessageTextViewLayout() {
            // In design space between bottom part of border
            // and bottom part of screen is 170 and screen height 812.
            // So since height is different for every other
            // device, we should rely on ratio.
            let bottomSpaceToScreenHeightRatio = 0.209
            NSLayoutConstraint.activate([
                messageTextView.trailingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.trailingAnchor,
                    constant: -Self.sideMargin
                ),
                messageTextView.heightAnchor.constraint(
                    greaterThanOrEqualTo: heightAnchor,
                    multiplier: bottomSpaceToScreenHeightRatio
                )
            ])
            rootStackView.setCustomSpacing(16, after: messageTextView)

        }

        func defineSendMessageButtonLayout() {
            let widthConstraint = sendMessageButton.widthAnchor.constraint(
                equalTo: messageTitleStackView.widthAnchor,
                // For some reason width constraint breaks if it is
                // exactly equal to `messageTitleStackView` width.
                // Making it slightly less, seem to resolve the issue.
                constant: -1
            )
            NSLayoutConstraint.activate([
                widthConstraint,
                sendMessageButton.heightAnchor.constraint(equalToConstant: 48)
            ])
        }

        @objc func handleCheckMessagesButtonTap() {
            props.checkMessageButtonTap()
        }

        @objc func handleFilePickerButtonTap() {
            props.filePickerButtonTap?()
        }

        @objc func handleSendMessageButtonTap() {
            props.sendMessageButtonTap()
        }

        @objc func handleContentViewTap() {
            endEditing(false)
        }

        func renderProps() {
            header.title = props.style.headerTitle
            header.backButton.tap = props.backButtonTap.execute
            header.closeButton.tap = props.backButtonTap.execute
            header.showCloseButton()

            titleLabel.text = props.style.welcomeTitleStyle.text
            titleLabel.font = props.style.welcomeTitleStyle.font
            titleLabel.textColor = props.style.welcomeTitleStyle.color

            subtitleLabel.text = props.style.welcomeSubtitleStyle.text
            subtitleLabel.font = props.style.welcomeSubtitleStyle.font
            subtitleLabel.textColor = props.style.welcomeSubtitleStyle.color

            messageTextView.props = props.messageTextViewProps

            checkMessagesButton.setTitle(props.style.checkMessagesButtonStyle.title, for: .normal)
            checkMessagesButton.titleLabel?.font = props.style.checkMessagesButtonStyle.font
            checkMessagesButton.setTitleColor(props.style.checkMessagesButtonStyle.color, for: .normal)
            checkMessagesButton.accessibilityLabel = "some acc. label"

            messageTitleLabel.text = props.style.messageTitleStyle.title
            messageTitleLabel.font = props.style.messageTitleStyle.font
            messageTitleLabel.textColor = props.style.messageTitleStyle.color

            sendMessageButton.setTitle(props.style.sendButtonStyle.title, for: .normal)
            sendMessageButton.setTitleColor(props.style.sendButtonStyle.textColor, for: .normal)
            sendMessageButton.backgroundColor = props.style.sendButtonStyle.backgroundColor
            backgroundColor = props.style.backgroundColor

            filePickerButton.isHidden = props.filePickerButtonTap == nil
        }
    }
}

extension SecureConversations.WelcomeView {
    class MessageTextView: View {
        struct Props: Equatable {
            let style: SecureConversations.WelcomeStyle.MessageTextViewStyle
            let text: String
            let textChanged: Command<String>
            let textLimit: Int
        }

        var props = Props(style: .initial, text: "", textChanged: .nop, textLimit: .max) {
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

        override func defineLayout() {
            super.defineLayout()
            defineTextViewLayout()
            definePlaceholderLabelLayout()
            renderProps()
        }

        func defineTextViewLayout() {
            addSubview(textView)
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
            addSubview(placeholderLabel)
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
            let style = props.style
            placeholderLabel.textColor = style.placeholderColor
            placeholderLabel.font = style.placeholderFont
            placeholderLabel.text = style.placeholderText

            textView.text = props.text
            textView.font = style.textFont
            textView.textColor = style.textColor
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            self.layer.borderWidth = style.borderWidth
            self.layer.cornerRadius = style.cornerRadius
            renderBorder()
        }

        func renderBorder() {
            self.layer.borderColor = textView.isFirstResponder
            ? props.style.activeBorderColor.cgColor
            : props.style.borderColor.cgColor
        }
    }
}

extension SecureConversations.WelcomeView.MessageTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        props.textChanged(textView.text)
    }

    public func textViewDidBeginEditing(_: UITextView) {
        placeholderLabel.isHidden = true
        renderBorder()
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        renderBorder()
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        textView.text.count + (text.count - range.length) <= props.textLimit
    }
}

extension SecureConversations.WelcomeView {
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: selector,
            name: notification,
            object: nil
        )
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] {
            scrollViewBottomConstraint?.constant = 0
            let duration = (durationValue as AnyObject).doubleValue ?? 0.3
            UIView.animate(withDuration: duration) {
                self.layoutIfNeeded()
            }
        }
    }

    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey],
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] {
            let endRect = self.convert((endValue as AnyObject).cgRectValue, from: window)
            scrollViewBottomConstraint?.constant = -endRect.height + (window?.safeAreaInsets.bottom ?? 0)
            let duration = (durationValue as AnyObject).doubleValue ?? 0.3
            UIView.animate(withDuration: duration) {
                self.layoutIfNeeded()
            }
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(
                bottomOffset,
                animated: true
            )

        }
    }
}

private extension SecureConversations.WelcomeStyle.MessageTextViewStyle {
    static let initial = Self(
        placeholderText: "",
        placeholderFont: .systemFont(ofSize: 12),
        placeholderColor: .black,
        textFont: .systemFont(ofSize: 12),
        textColor: .black,
        borderColor: .black,
        activeBorderColor: .black,
        borderWidth: 1,
        cornerRadius: 4
    )
}

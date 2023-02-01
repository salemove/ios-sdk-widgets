import Foundation
import UIKit

extension SecureConversations {
    final class WelcomeView: BaseView {
        static let sideMargin = 24.0
        static let filePickerButtonSize = 44.0

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

        lazy var sendMessageButton: SecureConversations.SendMessageButton = {
            let button = SecureConversations.SendMessageButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(
                self,
                action: #selector(handleSendMessageButtonTap),
                for: .touchUpInside
            )
            return button
        }()

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
                messageWarningStackView,
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

        lazy var messageWarningLabel = UILabel().make { label in
            label.numberOfLines = 0
        }

        lazy var messageWarningImageView = UIImageView().makeView { imageView in
            imageView.image = Asset.mcWarningIcon.image
        }

        lazy var messageWarningStackView = UIStackView(
            arrangedSubviews: [
            messageWarningImageView,
            messageWarningLabel
            ])
            .make { stackView in
                stackView.alignment = .center
                stackView.axis = .horizontal
                stackView.spacing = 5
            }

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

        @available(*, unavailable)
        required init() {
            fatalError("init() has not been implemented")
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
            defineMessageWarningLabelLayout()
            // Hide warning stack initially.
            setWarningStackHidden(true)
        }

        override func setup() {
            super.setup()
            subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
            subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
            renderProps()
        }

        @objc func handleCheckMessagesButtonTap() {
            props.checkMessageButtonTap()
        }

        @objc func handleFilePickerButtonTap() {
            props.filePickerButton?.tap()
        }

        @objc func handleSendMessageButtonTap() {
            Props.SendMessageButton.UIKitProps(props.sendMessageButton).tap?()
        }

        @objc func handleContentViewTap() {
            endEditing(false)
        }

        func renderProps() {
            header.title = props.style.headerTitle
            header.backButton.tap = props.backButtonTap.execute
            header.closeButton.tap = props.closeButtonTap.execute
            header.showCloseButton()

            titleIconView.tintColor = props.style.titleImageStyle.color

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

            switch props.sendMessageButton {
            case .active:
                sendMessageButton.props = .init(enabledStyle: props.style.sendButtonStyle.enabledStyle)
            case .disabled:
                sendMessageButton.props = .init(disabledStyle: props.style.sendButtonStyle.disabledStyle)
            case .loading:
                sendMessageButton.props = .init(loadingStyle: props.style.sendButtonStyle.loadingStyle)
            }

            backgroundColor = props.style.backgroundColor

            filePickerButton.isHidden = props.filePickerButton == nil
            filePickerButton.isEnabled = props.filePickerButton?.isEnabled == true
            filePickerButton.tintColor = filePickerButton.isEnabled
                ? props.style.filePickerButtonStyle.color
                : props.style.filePickerButtonStyle.disabledColor

            renderedWarning = props.warningMessage
        }

        var renderedWarning: Props.WarningMessage = "" {
            didSet {
                guard renderedWarning != oldValue else { return }

                let render = { [weak self] in
                    guard let self = self else { return }
                    self.setWarningStackHidden(self.renderedWarning.text.isEmpty)
                    self.messageWarningLabel.text = self.renderedWarning.text
                    self.messageWarningLabel.textColor = self.props.style.messageWarningStyle.textColor
                    self.messageWarningLabel.font = self.props.style.messageWarningStyle.textFont
                    self.messageWarningImageView.tintColor = self.props.style.messageWarningStyle.iconColor
                }

                // Render w/o animation
                if renderedWarning.animated {
                    UIView.animate(withDuration: 0.25, animations: render)
                } else {
                    render()
                }
            }
        }

        private func setWarningStackHidden(_ isHidden: Bool) {
            if isHidden {
                messageWarningStackView.isHidden = true
                rootStackView.setCustomSpacing(16, after: messageTextView)
                rootStackView.setCustomSpacing(0, after: messageWarningStackView)
            } else {
                messageWarningStackView.isHidden = false
                rootStackView.setCustomSpacing(4, after: messageTextView)
                rootStackView.setCustomSpacing(14, after: messageWarningStackView)
            }
        }
    }
}

// MARK: - Define layout
extension SecureConversations.WelcomeView {
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

    func defineMessageWarningLabelLayout() {
        NSLayoutConstraint.activate([
            messageWarningLabel.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -Self.sideMargin
            )
        ])
    }
}

// MARK: - Props
extension SecureConversations.WelcomeView {
    struct Props: Equatable {
        struct FilePickerButton: Equatable {
            let isEnabled: Bool
            let tap: Cmd
        }

        struct WarningMessage: Equatable {
            let text: String
            let animated: Bool
        }

        enum SendMessageButton: Equatable {
            case active(Cmd)
            case loading
            case disabled
        }

        let style: SecureConversations.WelcomeStyle
        let backButtonTap: Cmd
        let closeButtonTap: Cmd
        let checkMessageButtonTap: Cmd
        let filePickerButton: FilePickerButton?
        let sendMessageButton: SendMessageButton
        let messageTextViewProps: MessageTextView.Props
        let warningMessage: WarningMessage
    }
}

extension SecureConversations.WelcomeView.Props.WarningMessage: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        text = value
        animated = false
    }
}

// MARK: - MessageTextView
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
            self.layer.borderColor = style.borderColor.cgColor
            // Hide placeholder if textfield is active or has non-empty text.
            placeholderLabel.isHidden = !textView.text.isEmpty || textView.isFirstResponder
            renderedActive = props.isActive
        }

        var renderedActive: Bool = false {
            didSet {
                guard renderedActive != oldValue else { return }
                // Make text view active based on pass value from Props
                switch (renderedActive, textView.isFirstResponder) {
                case (true, true), (false, false):
                    break
                case (true, false):
                    textView.becomeFirstResponder()
                case (false, true):
                    textView.resignFirstResponder()
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
            backgroundColor: activeStyle.backgroundColor
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
            backgroundColor: disabledStyle.backgroundColor
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
            backgroundColor: normalStyle.backgroundColor
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

// MARK: - Keyboard handling in WelcomeView
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
            let bottomOffset = CGPoint(
                x: 0,
                y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
            )
            scrollView.setContentOffset(
                bottomOffset,
                animated: true
            )

        }
    }
}

private extension SecureConversations.WelcomeStyle.MessageTextViewStyle {
    static let initial = SecureConversations.WelcomeStyle.MessageTextViewStyle(
        normalStyle: .init(
            placeholderText: "",
            placeholderFont: .systemFont(ofSize: 12),
            placeholderColor: .black,
            textFont: .systemFont(ofSize: 12),
            textColor: .black,
            borderColor: .black,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: .black
        ),
        disabledStyle: .init(
            placeholderText: "",
            placeholderFont: .systemFont(ofSize: 12),
            placeholderColor: .black,
            textFont: .systemFont(ofSize: 12),
            textColor: .black,
            borderColor: .black,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: .lightGray
        ),
        activeStyle: .init(
            placeholderText: "",
            placeholderFont: .systemFont(ofSize: 12),
            placeholderColor: .black,
            textFont: .systemFont(ofSize: 12),
            textColor: .black,
            borderColor: .black,
            borderWidth: 1,
            cornerRadius: 4,
            backgroundColor: .blue
        )
    )
}

import Foundation
import UIKit

import Dispatch

extension SecureConversations {
    final class WelcomeView: BaseView {
        static let sideMargin = 16.0
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

        lazy var messageTextView = MessageTextView(environment: .create(with: environment)).makeView()

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
                fileUploadListView,
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
            ]
        )
        .make { stackView in
            stackView.alignment = .center
            stackView.axis = .horizontal
            stackView.spacing = 5
        }

        let fileUploadListView: FileUploadListView
        let environment: Environemnt

        // Since some of the reusable views require style
        // to be passed during initialization, we have to
        // provide `Props` also during initialization, because
        // it is single source of data (including styles)
        // for the data-driven view.
        init(props: Props, environment: Environemnt) {
            self.header = Header(props: props.headerProps)
            self.props = props
            self.environment = environment
            self.fileUploadListView = .init(environment: .create(with: environment)).makeView()
            super.init()
            // Hide warning stack initially.
            setWarningStackHidden(true)
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
            defineFileUploadListViewLayout()
            renderProps()
        }

        override func setup() {
            super.setup()
            subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
            subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
            addSubview(scrollView)
            scrollView.addSubview(rootStackView)
        }

        @objc func handleCheckMessagesButtonTap() {
            props.checkMessageButtonTap()
        }

        @objc func handleFilePickerButtonTap() {
            props.filePickerButton?.tap(filePickerButton)
        }

        @objc func handleSendMessageButtonTap() {
            if let sendMessageButtonProps = props.sendMessageButton {
                Props.SendMessageButton.UIKitProps(sendMessageButtonProps).tap?()
            }
        }

        @objc func handleContentViewTap() {
            endEditing(false)
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

// MARK: - Render props
extension SecureConversations.WelcomeView {
    func renderProps() {
        header.props = props.headerProps
        header.showCloseButton()

        titleIconView.tintColor = props.style.titleImageStyle.color

        titleLabel.text = props.style.welcomeTitleStyle.text
        titleLabel.font = props.style.welcomeTitleStyle.font
        titleLabel.textColor = props.style.welcomeTitleStyle.color
        setFontScalingEnabled(
            props.style.welcomeTitleStyle.accessibility.isFontScalingEnabled,
            for: titleLabel
        )
        titleLabel.accessibilityIdentifier = "secureConversations_welcomeTitle_label"

        subtitleLabel.text = props.style.welcomeSubtitleStyle.text
        subtitleLabel.font = props.style.welcomeSubtitleStyle.font
        subtitleLabel.textColor = props.style.welcomeSubtitleStyle.color
        setFontScalingEnabled(
            props.style.welcomeSubtitleStyle.accessibility.isFontScalingEnabled,
            for: subtitleLabel
        )

        messageTextView.isHidden = props.messageTextViewProps == nil
        if let messageTextViewProps = props.messageTextViewProps {
            messageTextView.props = messageTextViewProps
        }

        renderCheckMessagesButtonProps()

        messageTitleLabel.isHidden = props.style.messageTitleStyle == nil
        if let messageTitleStyle = props.style.messageTitleStyle {
            messageTitleLabel.text = messageTitleStyle.title
            messageTitleLabel.font = messageTitleStyle.font
            messageTitleLabel.textColor = messageTitleStyle.color

            setFontScalingEnabled(
                messageTitleStyle.accessibility.isFontScalingEnabled,
                for: messageTitleLabel
            )
        }

        renderSendMessageButtonProps()

        backgroundColor = props.style.backgroundColor

        filePickerButton.isHidden = props.filePickerButton == nil
        filePickerButton.isEnabled = props.filePickerButton?.isEnabled == true
        filePickerButton.tintColor = filePickerButton.isEnabled
            ? props.style.filePickerButtonStyle.color
            : props.style.filePickerButtonStyle.disabledColor
        filePickerButton.accessibilityTraits = .button
        filePickerButton.accessibilityIdentifier = "secureConversations_welcomeFilePicker_button"
        filePickerButton.accessibilityLabel = props.style.filePickerButtonStyle.accessibility.label
        filePickerButton.accessibilityHint = props.style.filePickerButtonStyle.accessibility.hint
        setFontScalingEnabled(
            props.style.filePickerButtonStyle.accessibility.isFontScalingEnabled,
            for: filePickerButton
        )

        renderedWarning = props.warningMessage

        fileUploadListView.props = props.fileUploadListProps

        rootStackView.setCustomSpacing(
            props.fileUploadListProps.uploads.isEmpty ? 0 : 16,
            after: fileUploadListView
        )

        rootStackView.isHidden = props.isUiHidden
    }

    private func renderCheckMessagesButtonProps() {
        checkMessagesButton.setTitle(props.style.checkMessagesButtonStyle.title, for: .normal)
        checkMessagesButton.titleLabel?.font = props.style.checkMessagesButtonStyle.font
        checkMessagesButton.setTitleColor(props.style.checkMessagesButtonStyle.color, for: .normal)
        checkMessagesButton.accessibilityLabel = props.style.checkMessagesButtonStyle.accessibility.label
        checkMessagesButton.accessibilityHint = props.style.checkMessagesButtonStyle.accessibility.hint
        checkMessagesButton.accessibilityTraits = .button
        checkMessagesButton.accessibilityIdentifier = "secureConversations_welcomeCheckMessages_button"

        setFontScalingEnabled(
            props.style.checkMessagesButtonStyle.accessibility.isFontScalingEnabled,
            for: checkMessagesButton
        )
    }

    private func renderSendMessageButtonProps() {
        sendMessageButton.isHidden = props.sendMessageButton == nil
        if let sendMessageButtonProps = props.sendMessageButton {
            switch sendMessageButtonProps {
            case .active:
                sendMessageButton.props = .init(enabledStyle: props.style.sendButtonStyle.enabledStyle)
            case .disabled:
                sendMessageButton.props = .init(disabledStyle: props.style.sendButtonStyle.disabledStyle)
            case .loading:
                sendMessageButton.props = .init(loadingStyle: props.style.sendButtonStyle.loadingStyle)
            }
        }
    }
}

// MARK: - Define layout
extension SecureConversations.WelcomeView {
    func defineHeaderLayout() {
        addSubview(header)
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += header.layoutInSuperview(edges: .horizontal)
        constraints += header.layoutInSuperview(edges: .top)
    }

    func defineScrollViewLayout() {
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
            equalTo: messageTextView.widthAnchor
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

    func defineFileUploadListViewLayout() {
        NSLayoutConstraint.activate([
            fileUploadListView.trailingAnchor.constraint(
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
            let tap: Command<UIView>
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
        let checkMessageButtonTap: Cmd
        let filePickerButton: FilePickerButton?
        let sendMessageButton: SendMessageButton?
        let messageTextViewProps: MessageTextView.Props?
        let warningMessage: WarningMessage
        let fileUploadListProps: SecureConversations.FileUploadListView.Props
        let headerProps: Header.Props
        let isUiHidden: Bool
    }
}

extension SecureConversations.WelcomeView.Props.WarningMessage: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        text = value
        animated = false
    }
}

// MARK: - Keyboard handling in WelcomeView
extension SecureConversations.WelcomeView {
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        environment.notificationCenter.addObserver(
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
                // Scroll content to the location of message text view,
                // so that it would become visible initially when keyboard
                // is shown, for portrait and landscape screen orientations.
                y: messageTextView.frame.origin.y
            )
            scrollView.setContentOffset(
                bottomOffset,
                animated: true
            )
        }
    }
}

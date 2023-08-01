import UIKit

class ChatMessageEntryView: BaseView {
    let pickMediaButton: MessageButton
    let uploadListView: SecureConversations.FileUploadListView
    var textChanged: ((String) -> Void)?
    var sendTapped: (() -> Void)?
    var pickMediaTapped: (() -> Void)?
    var messageText: String {
        get { return textView.text }
        set {
            textView.text = newValue
            placeholderLabel.isHidden = !textView.text.isEmpty
            updateTextViewHeight()
        }
    }

    var isChoiceCardModeEnabled: Bool {
        didSet {
            updatePickMediaButtonVisibility(mediaPickerButtonVisibility)
            updatePlaceholderText()
        }
    }

    var isConnected: Bool {
        didSet {
            updatePlaceholderText()
            updatePickMediaButtonVisibility(mediaPickerButtonVisibility)
        }
    }

    var showsSendButton: Bool {
        get { return !sendButton.isHidden }
        set { sendButton.isHidden = !newValue }
    }

    var isEnabled: Bool {
        get { return isUserInteractionEnabled }
        set { isUserInteractionEnabled = newValue }
    }

    var mediaPickerButtonVisibility: MediaPickerButtonVisibility = .disabled
    var textViewHeightConstraint: NSLayoutConstraint?

    let textView = UITextView()
    let maxTextLines = 4
    private let style: ChatMessageEntryStyle
    private let separator = UIView()
    private let messageContainerView = UIView()
    private let placeholderLabel = UILabel()
    private let sendButton: MessageButton
    private let buttonsStackView = UIStackView()
    private let minTextViewHeight: CGFloat = 24
    private let maxCharacters = 10000

    private let environment: Environment

    public init(
        with style: ChatMessageEntryStyle,
        environment: Environment
    ) {
        self.style = style
        self.environment = environment
        uploadListView = SecureConversations.FileUploadListView(
            environment: .init(uiScreen: environment.uiScreen)
        )
        pickMediaButton = MessageButton(with: style.mediaButton)
        sendButton = MessageButton(with: style.sendButton)
        isChoiceCardModeEnabled = false
        isConnected = false
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateTextViewHeight()
    }

    func updateLayout() {
        // Height updates work only with delay
        environment.gcd.mainQueue.asyncAfterDeadline(.now() + 0.1) {
            self.updateTextViewHeight()
            self.uploadListView.updateHeight()
        }
    }

    override func setup() {
        super.setup()
        backgroundColor = style.backgroundColor

        separator.backgroundColor = style.separatorColor

        messageContainerView.backgroundColor = style.backgroundColor

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(textViewContainerTap)
        )
        messageContainerView.addGestureRecognizer(tapRecognizer)
        messageContainerView.accessibilityIdentifier = "chat_messageContainerView"

        textView.accessibilityIdentifier = "chat_textView"
        textView.delegate = self
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.autocapitalizationType = .sentences
        textView.font = style.messageFont
        textView.textColor = style.messageColor
        textView.backgroundColor = .clear
        textView.accessibilityLabel = style.accessibility.messageInputAccessibilityLabel

        textView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        placeholderLabel.font = style.placeholderFont
        placeholderLabel.textColor = style.placeholderColor
        placeholderLabel.isUserInteractionEnabled = false
        placeholderLabel.accessibilityIdentifier = "chat_textEntryPlaceholderLabel"
        updatePlaceholderText()

        pickMediaButton.tap = { [weak self] in self?.pickMediaTapped?() }
        pickMediaButton.accessibilityLabel = style.mediaButton.accessibility.accessibilityLabel
        updatePickMediaButtonVisibility(.disabled)

        sendButton.accessibilityIdentifier = "chat_sendButton"
        sendButton.tap = { [weak self] in self?.sendTap() }
        sendButton.accessibilityLabel = style.sendButton.accessibility.accessibilityLabel
        showsSendButton = false

        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 16
        buttonsStackView.addArrangedSubviews([pickMediaButton, sendButton])
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: textView
        )
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: placeholderLabel
        )
    }

    override func defineLayout() {
        super.defineLayout()
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }

        addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        constraints += separator.match(.height, value: 1)
        constraints += separator.layoutInSuperview(edges: .horizontal)
        constraints += separator.layoutInSuperview(edges: .top)

        addSubview(uploadListView)
        uploadListView.translatesAutoresizingMaskIntoConstraints = false
        constraints += uploadListView.topAnchor.constraint(equalTo: separator.bottomAnchor)
        constraints += uploadListView.layoutInSuperview(edges: .horizontal)

        addSubview(messageContainerView)
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        constraints += messageContainerView.topAnchor.constraint(equalTo: uploadListView.bottomAnchor)
        constraints += messageContainerView.layoutInSuperview(edges: .horizontal)
        constraints += messageContainerView.layoutIn(safeAreaLayoutGuide, edges: .bottom)

        messageContainerView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textViewHeightConstraint = textView.match(.height, value: minTextViewHeight).first
        constraints += [textViewHeightConstraint].compactMap { $0 }
        constraints += textView.layoutInSuperview(edges: .vertical, insets: .init(top: 13, left: 16, bottom: 13, right: 32))
        constraints += textView.layoutInSuperview(edges: .leading, insets: .init(top: 13, left: 16, bottom: 13, right: 32))
        constraints += textView.trailingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor, constant: -8)

        messageContainerView.addSubview(placeholderLabel)
        placeholderLabel.isAccessibilityElement = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.numberOfLines = 0

        constraints += placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor)
        constraints += placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor)
        constraints += placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor)

        addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        constraints += buttonsStackView.match(.height, value: 50)
        constraints += buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        constraints += buttonsStackView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor)

        updateTextViewHeight()
    }

    private func updatePlaceholderText() {
        var text: String

        if isChoiceCardModeEnabled {
            text = style.choiceCardPlaceholder
        } else if !isConnected {
            text = style.startEngagementPlaceholder
        } else {
            text = style.enterMessagePlaceholder
        }

        placeholderLabel.text = text
    }

    private func updatePickMediaButtonVisibility(_ visibility: MediaPickerButtonVisibility) {
        pickMediaButton.isHidden = visibility.isHidden
    }

    private func updateTextViewHeight() {
        let size = CGSize(
            width: textView.frame.size.width,
            height: CGFloat.greatestFiniteMagnitude
        )

        guard let font = textView.font, font.lineHeight > 0 else {
            return
        }

        let estimatedTextViewHeight = textView.sizeThatFits(size).height
        let estimatedPlaceholderHeight = placeholderLabel.sizeThatFits(size).height

        var newHeight = max(estimatedTextViewHeight, estimatedPlaceholderHeight)

        let numLines = estimatedTextViewHeight / font.lineHeight

        textView.isScrollEnabled = Int(numLines) > maxTextLines

        if Int(numLines) > maxTextLines {
            newHeight = font.lineHeight * CGFloat(maxTextLines)
        }

        textViewHeightConstraint?.constant = newHeight
    }

    private func sendTap() {
        sendTapped?()
    }

    @objc private func textViewContainerTap() {
        textView.becomeFirstResponder()
    }
}

extension ChatMessageEntryView: UITextViewDelegate {
    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(
            in: range,
            with: text
        )
        return newText.count < maxCharacters
    }

    public func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
        textChanged?(textView.text)
    }

    public func textViewDidBeginEditing(_: UITextView) {
        placeholderLabel.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension ChatMessageEntryView {
    struct Environment {
        var gcd: GCD
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
    }
}

extension ChatMessageEntryView {
    func setPickMediaButtonVisibility(_ visibility: MediaPickerButtonVisibility) {
        mediaPickerButtonVisibility = visibility
        updatePickMediaButtonVisibility(visibility)
    }
}

enum MediaPickerButtonVisibility {
    enum ToggledBy {
        case choiceCard
        case enagagementConnection(isConnected: Bool)
        case secureMessaging
    }
    case enabled(ToggledBy)
    case disabled
}

extension MediaPickerButtonVisibility {
    var isHidden: Bool {
        switch self {
        case .disabled:
            return true
        case .enabled(.choiceCard):
            return true
        case let .enabled(.enagagementConnection(isConnected)):
            return !isConnected
        case .enabled(.secureMessaging):
            return false
        }
    }
}

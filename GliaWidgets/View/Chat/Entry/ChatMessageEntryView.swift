import UIKit

class ChatMessageEntryView: UIView {
    let pickMediaButton: MessageButton
    let uploadListView: FileUploadListView
    var maxCharacters: Int = 200
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
            isEnabled = !isChoiceCardModeEnabled
            if isChoiceCardModeEnabled {
                textView.resignFirstResponder()
            }

            updatePickMediaButtonVisibility()
            updatePlaceholderText()
        }
    }

    var isAttachmentButtonHidden: Bool {
        didSet {
            updatePickMediaButtonVisibility()
        }
    }

    var isConnected: Bool {
        didSet {
            updatePlaceholderText()
            updatePickMediaButtonVisibility()
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

    private let style: ChatMessageEntryStyle
    private let separator = UIView()
    private let messageContainerView = UIView()
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    private let sendButton: MessageButton
    private let buttonsStackView = UIStackView()
    private var textViewHeightConstraint: NSLayoutConstraint!
    private let kMinTextViewHeight: CGFloat = 24
    private let kMaxTextViewHeight: CGFloat = 200

    public init(with style: ChatMessageEntryStyle) {
        self.style = style
        uploadListView = FileUploadListView(with: style.uploadList)
        pickMediaButton = MessageButton(with: style.mediaButton)
        sendButton = MessageButton(with: style.sendButton)
        isChoiceCardModeEnabled = false
        isAttachmentButtonHidden = true
        isConnected = false
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateTextViewHeight()
    }

    private func setup() {
        backgroundColor = style.backgroundColor

        separator.backgroundColor = style.separatorColor

        messageContainerView.backgroundColor = style.backgroundColor

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(textViewContainerTap)
        )
        messageContainerView.addGestureRecognizer(tapRecognizer)

        textView.delegate = self
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.autocapitalizationType = .sentences
        textView.isScrollEnabled = false
        textView.font = style.messageFont
        textView.textColor = style.messageColor
        textView.backgroundColor = .clear
        textView.accessibilityLabel = "Message"

        placeholderLabel.font = style.placeholderFont
        placeholderLabel.textColor = style.placeholderColor
        updatePlaceholderText()

        pickMediaButton.tap = { [weak self] in self?.pickMediaTapped?() }
        pickMediaButton.accessibilityLabel = "Pick media"
        updatePickMediaButtonVisibility()

        sendButton.tap = { [weak self] in self?.sendTap() }
        sendButton.accessibilityLabel = "Send"
        showsSendButton = false

        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 15
        buttonsStackView.addArrangedSubviews([pickMediaButton, sendButton])
    }

    private func layout() {
        messageContainerView.addSubview(textView)
        textViewHeightConstraint = textView.autoSetDimension(
            .height,
            toSize: kMinTextViewHeight
        )

        textView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        textView.autoPinEdge(toSuperviewEdge: .top, withInset: 13)
        textView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 13)
        textView.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
        textView.autoAlignAxis(toSuperviewAxis: .horizontal)

        textView.addSubview(placeholderLabel)
        placeholderLabel.autoPinEdge(toSuperviewEdge: .left)
        placeholderLabel.autoPinEdge(toSuperviewEdge: .top)
        placeholderLabel.autoPinEdge(toSuperviewEdge: .right)

        addSubview(separator)
        addSubview(uploadListView)
        addSubview(messageContainerView)

        separator.autoSetDimension(.height, toSize: 1)
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)

        uploadListView.autoPinEdge(.top, to: .bottom, of: separator)
        uploadListView.autoPinEdge(.bottom, to: .top, of: messageContainerView)
        uploadListView.autoPinEdge(toSuperviewEdge: .left)
        uploadListView.autoPinEdge(toSuperviewEdge: .right)

        messageContainerView.autoPinEdge(.top, to: .bottom, of: uploadListView)
        messageContainerView.autoPinEdge(toSuperviewEdge: .left)
        messageContainerView.autoPinEdge(toSuperviewEdge: .bottom)

        addSubview(buttonsStackView)
        buttonsStackView.autoSetDimension(.height, toSize: 50)
        buttonsStackView.autoSetDimension(.width, toSize: 72, relation: .lessThanOrEqual)
        buttonsStackView.autoPinEdge(.left, to: .right, of: messageContainerView)
        buttonsStackView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        buttonsStackView.autoPinEdge(toSuperviewEdge: .bottom)

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

    private func updatePickMediaButtonVisibility() {
        if isChoiceCardModeEnabled || !isConnected {
            pickMediaButton.isHidden = true
        } else {
            pickMediaButton.isHidden = isAttachmentButtonHidden
        }
    }

    private func updateTextViewHeight() {
        let size = CGSize(
            width: textView.frame.size.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        var newHeight = textView.sizeThatFits(size).height

        textView.isScrollEnabled = newHeight > kMaxTextViewHeight

        if newHeight > kMaxTextViewHeight {
            newHeight = kMaxTextViewHeight
        } else if newHeight < kMinTextViewHeight {
            newHeight = kMinTextViewHeight
        }

        textViewHeightConstraint.constant = newHeight
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

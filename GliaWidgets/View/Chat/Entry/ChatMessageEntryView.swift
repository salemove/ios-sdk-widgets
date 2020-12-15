import UIKit

public class ChatMessageEntryView: UIView {
    var maxCharacters: Int = 1000
    var textMessageEntered: ((String) -> Void)?
    var pickMediaTapped: (() -> Void)?

    private let style: ChatMessageEntryStyle
    private let separator = UIView()
    private let messageContainerView = UIView()
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    private let pickMediaButton = Button(kind: .chatPickMedia)
    private let sendButton = Button(kind: .chatSend)
    private var textViewHeightConstraint: NSLayoutConstraint!
    private let kMinTextViewContainerHeight: CGFloat = 50
    private let kMinTextViewHeight: CGFloat = 20
    private let kMaxTextViewHeight: CGFloat = 200

    public init(with style: ChatMessageEntryStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = style.backgroundColor

        separator.backgroundColor = style.separatorColor

        messageContainerView.backgroundColor = style.backgroundColor

        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(textViewContainerTap))
        messageContainerView.addGestureRecognizer(tapRecognizer)

        textView.delegate = self
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.autocapitalizationType = .none
        textView.isScrollEnabled = false
        textView.font = style.messageFont
        textView.textColor = style.messageColor

        placeholderLabel.text = style.placeholder
        placeholderLabel.font = style.placeholderFont
        placeholderLabel.textColor = style.placeholderColor

        sendButton.tintColor = style.sendButtonColor

        pickMediaButton.tap = { [weak self] in self?.pickMediaTapped?() }
        sendButton.tap = { [weak self] in self?.sendTapped() }
    }

    private func layout() {
        addSubview(separator)
        separator.autoSetDimension(.height, toSize: 1)
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)

        messageContainerView.addSubview(pickMediaButton)
        pickMediaButton.autoPinEdge(toSuperviewEdge: .top, withInset: 4)
        pickMediaButton.autoPinEdge(toSuperviewEdge: .left, withInset: 4)

        messageContainerView.addSubview(textView)
        textViewHeightConstraint = textView.autoSetDimension(.height,
                                                             toSize: kMinTextViewHeight,
                                                             relation: .greaterThanOrEqual)
        textView.autoPinEdge(.left, to: .right, of: pickMediaButton, withOffset: 16)
        textView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        textView.autoPinEdge(toSuperviewEdge: .top, withInset: 13)
        textView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 13)

        textView.addSubview(placeholderLabel)
        placeholderLabel.autoPinEdge(toSuperviewEdge: .left)
        placeholderLabel.autoPinEdge(toSuperviewEdge: .top)

        addSubview(messageContainerView)
        messageContainerView.autoSetDimension(.height,
                                           toSize: kMinTextViewContainerHeight,
                                           relation: .greaterThanOrEqual)
        messageContainerView.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        messageContainerView.autoPinEdge(toSuperviewEdge: .top, withInset: 16, relation: .lessThanOrEqual)
        messageContainerView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16, relation: .lessThanOrEqual)

        addSubview(sendButton)
        sendButton.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        sendButton.autoPinEdge(.left, to: .right, of: messageContainerView)
        sendButton.autoAlignAxis(.horizontal, toSameAxisOf: messageContainerView)

        updateTextFieldHeight()
        updateSendButton()
    }

    private func updateTextFieldHeight() {
        let size = CGSize(width: textView.frame.size.width,
                          height: CGFloat.greatestFiniteMagnitude)
        var newHeight = textView.sizeThatFits(size).height

        textView.isScrollEnabled = newHeight > kMaxTextViewHeight

        if newHeight > kMaxTextViewHeight {
            newHeight = kMaxTextViewHeight
        } else if newHeight < kMinTextViewHeight {
            newHeight = kMinTextViewHeight
        }

        textViewHeightConstraint.constant = newHeight
    }

    private func updateSendButton() {
        sendButton.isEnabled = !textView.text.isEmpty
    }

    private func sendTapped() {
        let text = textView.text ?? ""
        textMessageEntered?(text)
        textView.text = ""
        updateTextFieldHeight()
        updateSendButton()
    }

    @objc private func textViewContainerTap() {
        textView.becomeFirstResponder()
    }
}

extension ChatMessageEntryView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < maxCharacters
    }

    public func textViewDidChange(_ textView: UITextView) {
        updateTextFieldHeight()
        updateSendButton()
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

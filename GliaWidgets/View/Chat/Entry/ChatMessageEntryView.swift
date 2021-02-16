import UIKit

public class ChatMessageEntryView: UIView {
    var maxCharacters: Int = 200
    var textChanged: ((String) -> Void)?
    var sendTapped: ((String) -> Void)?
    var pickMediaTapped: (() -> Void)?
    var message: String {
        get { return textView.text }
        set { textView.text = newValue }
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
    private let pickMediaButton: MessageButton
    private let sendButton: MessageButton
    private let buttonsStackView = UIStackView()
    private var textViewHeightConstraint: NSLayoutConstraint!
    private let kMinTextViewHeight: CGFloat = 24
    private let kMaxTextViewHeight: CGFloat = 200

    public init(with style: ChatMessageEntryStyle) {
        self.style = style
        pickMediaButton = MessageButton(with: style.mediaButton)
        sendButton = MessageButton(with: style.sendButton)
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateTextFieldHeight()
    }

    func setSendButtonVisible(_ visible: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.sendButton.isHidden = !visible
            self.sendButton.alpha = visible ? 1.0 : 0.0
        }
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
        textView.autocapitalizationType = .sentences
        textView.isScrollEnabled = false
        textView.font = style.messageFont
        textView.textColor = style.messageColor
        textView.backgroundColor = .clear

        placeholderLabel.text = style.placeholder
        placeholderLabel.font = style.placeholderFont
        placeholderLabel.textColor = style.placeholderColor

        sendButton.isHidden = true
        sendButton.alpha = 0.0

        pickMediaButton.tap = { [weak self] in self?.pickMediaTapped?() }
        sendButton.tap = { [weak self] in self?.sendTap() }

        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 15
        buttonsStackView.addArrangedSubviews([pickMediaButton, sendButton])
    }

    private func layout() {
        messageContainerView.addSubview(textView)
        textViewHeightConstraint = textView.autoSetDimension(.height,
                                                             toSize: kMinTextViewHeight)

        textView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        textView.autoPinEdge(toSuperviewEdge: .top, withInset: 13)
        textView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 13)
        textView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        textView.autoAlignAxis(toSuperviewAxis: .horizontal)

        textView.addSubview(placeholderLabel)
        placeholderLabel.autoPinEdge(toSuperviewEdge: .left)
        placeholderLabel.autoPinEdge(toSuperviewEdge: .top)

        addSubview(messageContainerView)
        messageContainerView.autoPinEdgesToSuperviewEdges(with: .zero,
                                                          excludingEdge: .right)

        addSubview(buttonsStackView)
        buttonsStackView.autoPinEdge(.left, to: .right, of: messageContainerView, withOffset: 16)
        buttonsStackView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        buttonsStackView.autoPinEdge(toSuperviewEdge: .top)
        buttonsStackView.autoPinEdge(toSuperviewEdge: .bottom)
        buttonsStackView.autoAlignAxis(toSuperviewAxis: .horizontal)

        addSubview(separator)
        separator.autoSetDimension(.height, toSize: 1)
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)

        updateTextFieldHeight()
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

    private func sendTap() {
        let text = textView.text ?? ""
        sendTapped?(text)
        textView.text = ""
        updateTextFieldHeight()
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
        textChanged?(textView.text)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

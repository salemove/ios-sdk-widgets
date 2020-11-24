import UIKit

class SentChatMessageView: UIView {
    private let style: SentChatMessageStyle
    private let contentViews = UIStackView()
    private let statusView = ChatMessageStatusView()
    private let kInsets = UIEdgeInsets(top: 5, left: 88, bottom: 5, right: 16)

    init(with style: SentChatMessageStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addContent(_ content: ChatMessageContent) {
        switch content {
        case .text(let text):
            let messageLabel = UILabel()
            messageLabel.font = style.messageFont
            messageLabel.textColor = style.messageColor
            messageLabel.numberOfLines = 0
            messageLabel.text = text
            let insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            let contentView = ChatMessageContentView(with: messageLabel,
                                                     insets: insets)
            contentView.backgroundColor = style.backgroundColor
            contentViews.addArrangedSubview(contentView)
        case .image:
            break
        }
    }

    private func setup() {
        contentViews.axis = .vertical
        contentViews.spacing = 4
    }

    private func layout() {
        addSubview(contentViews)
        contentViews.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top)
        contentViews.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right)
        contentViews.autoPinEdge(toSuperviewEdge: .left, withInset: kInsets.left, relation: .greaterThanOrEqual)

        addSubview(statusView)
        statusView.autoPinEdge(.top, to: .bottom, of: contentViews, withOffset: 2)
        statusView.autoPinEdge(toSuperviewEdge: .right)
        statusView.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)
    }
}

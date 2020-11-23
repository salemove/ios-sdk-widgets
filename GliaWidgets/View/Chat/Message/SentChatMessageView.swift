import UIKit

class SentChatMessageView: UIView {
    var content: ChatMessageContent = .none {
        didSet { setContent(content) }
    }

    private let style: SentChatMessageStyle
    private let contentView = UIView()
    private let messageLabel = UILabel()
    private let statusView = ChatMessageStatusView()
    private let kContentInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    private let kMaxContentWidth: CGFloat = 271
    private let kMinContentWidth: CGFloat = 32

    init(with style: SentChatMessageStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.backgroundColor = style.backgroundColor
        contentView.layer.cornerRadius = 10

        messageLabel.font = style.messageFont
        messageLabel.textColor = style.messageColor
        messageLabel.numberOfLines = 0
    }

    private func layout() {
        addSubview(contentView)
        contentView.autoPinEdge(toSuperviewEdge: .top)
        contentView.autoPinEdge(toSuperviewEdge: .right)
        contentView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        contentView.autoSetDimension(.width, toSize: kMaxContentWidth, relation: .lessThanOrEqual)
        contentView.autoSetDimension(.width, toSize: kMinContentWidth, relation: .greaterThanOrEqual)

        contentView.addSubview(messageLabel)
        messageLabel.autoPinEdgesToSuperviewEdges(with: kContentInsets)

        addSubview(statusView)
        statusView.autoPinEdge(.top, to: .bottom, of: contentView, withOffset: 2)
        statusView.autoPinEdge(toSuperviewEdge: .right)
        statusView.autoPinEdge(toSuperviewEdge: .bottom)
    }

    private func setContent(_ content: ChatMessageContent) {
        switch content {
        case .none:
            messageLabel.text = nil
        case .text(let text):
            messageLabel.text = text
        }
    }
}

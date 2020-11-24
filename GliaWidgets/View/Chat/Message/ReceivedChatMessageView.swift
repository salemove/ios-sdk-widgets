import UIKit

class ReceivedChatMessageView: UIView {
    var content: ChatMessageContent = .none {
        didSet { setContent(content) }
    }

    private let style: ReceivedChatMessageStyle
    private let contentView = UIView()
    private let messageLabel = UILabel()
    private let operatorImageView = UIImageView()
    private let kInsets = UIEdgeInsets(top: 5, left: 4, bottom: 5, right: 16)
    private let kContentInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    private let kMaxContentWidth: CGFloat = 271
    private let kMinContentWidth: CGFloat = 32

    init(with style: ReceivedChatMessageStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
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
        addSubview(operatorImageView)
        operatorImageView.autoPinEdge(toSuperviewEdge: .left, withInset: kInsets.left)
        operatorImageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)

        addSubview(contentView)
        contentView.autoPinEdge(.left, to: .right, of: operatorImageView, withOffset: 4)
        contentView.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top)
        contentView.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)
        contentView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        contentView.autoSetDimension(.width, toSize: kMaxContentWidth, relation: .lessThanOrEqual)

        contentView.addSubview(messageLabel)
        messageLabel.autoPinEdgesToSuperviewEdges(with: kContentInsets)
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

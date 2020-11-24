import UIKit

class ReceivedChatMessageView: UIView {
    private let style: ReceivedChatMessageStyle
    private let contentViews = UIStackView()
    private let operatorImageView = UIImageView()
    private let kInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 88)

    init(with style: ReceivedChatMessageStyle) {
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
        addSubview(operatorImageView)
        operatorImageView.autoPinEdge(toSuperviewEdge: .left, withInset: kInsets.left)
        operatorImageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)

        addSubview(contentViews)
        contentViews.autoPinEdge(.left, to: .right, of: operatorImageView, withOffset: 4)
        contentViews.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top)
        contentViews.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)
        contentViews.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right, relation: .greaterThanOrEqual)
    }
}

import UIKit

class ChatMessageView: UIView {
    let style: ChatMessageStyle
    let contentViews = UIStackView()

    init(with style: ChatMessageStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func appendContent(_ content: ChatMessageContent, animated: Bool) {
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
            appendContentView(contentView, animated: animated)
        case .image:
            break
        }
    }

    func appendContentView(_ contentView: UIView, animated: Bool) {
        contentViews.addArrangedSubview(contentView)
        contentView.isHidden = animated

        if animated {
            contentViews.layoutIfNeeded()

            UIView.animate(withDuration: 0.3) {
                contentView.isHidden = false
                self.contentViews.layoutIfNeeded()
            }
        }
    }

    func setup() {
        contentViews.axis = .vertical
        contentViews.spacing = 4
    }
}

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
            let contentView = ChatMessageTextContentView(with: style.text)
            contentView.text = text
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

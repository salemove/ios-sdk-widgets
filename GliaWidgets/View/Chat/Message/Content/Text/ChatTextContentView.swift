import UIKit

class ChatTextContentView: UIView {
    var text: String? {
        get { return textLabel.text }
        set { setText(newValue) }
    }

    private let textLabel = UILabel()
    private let style: ChatTextContentStyle
    private let contentAlignment: ChatMessageContentAlignment
    private let contentView = UIView()
    private let kInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    init(with style: ChatTextContentStyle, contentAlignment: ChatMessageContentAlignment) {
        self.style = style
        self.contentAlignment = contentAlignment
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

        textLabel.font = style.textFont
        textLabel.textColor = style.textColor
        textLabel.numberOfLines = 0
    }

    private func layout() {
        addSubview(contentView)
        contentView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
        contentView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)

        switch contentAlignment {
        case .left:
            contentView.autoPinEdge(toSuperviewEdge: .left)
        case .right:
            contentView.autoPinEdge(toSuperviewEdge: .right)
        }
    }

    private func setText(_ text: String?) {
        if text == nil || text?.isEmpty == true {
            textLabel.removeFromSuperview()
        } else {
            if textLabel.superview == nil {
                contentView.addSubview(textLabel)
                textLabel.autoPinEdgesToSuperviewEdges(with: kInsets)
            }
            textLabel.text = text
        }
    }
}

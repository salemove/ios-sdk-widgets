import UIKit

class ChatTextContentView: UIView {
    var text: String? {
        get { return textLabel.text }
        set { textLabel.text = newValue }
    }

    private let textLabel = UILabel()
    private let style: ChatTextContentStyle
    private let kInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    init(with style: ChatTextContentStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = style.backgroundColor
        layer.cornerRadius = 10

        textLabel.font = style.textFont
        textLabel.textColor = style.textColor
        textLabel.numberOfLines = 0
    }

    private func layout() {
        addSubview(textLabel)
        textLabel.autoPinEdgesToSuperviewEdges(with: kInsets)
    }
}

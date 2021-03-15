import UIKit

class ChatTextContentView: UIView {
    var text: String? {
        get { return textLabel.text }
        set { setText(newValue) }
    }

    private let textLabel = UILabel()
    private let style: ChatTextContentStyle
    private let kInsets: UIEdgeInsets

    init(with style: ChatTextContentStyle, withZeroInsets: Bool = false) {
        self.style = style
        self.kInsets = withZeroInsets
            ? UIEdgeInsets.zero
            : UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
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

    private func layout() {}

    private func setText(_ text: String?) {
        if text == nil || text?.isEmpty == true {
            textLabel.removeFromSuperview()
        } else {
            if textLabel.superview == nil {
                addSubview(textLabel)
                textLabel.autoPinEdgesToSuperviewEdges(with: kInsets)
            }
            textLabel.text = text
        }
    }
}

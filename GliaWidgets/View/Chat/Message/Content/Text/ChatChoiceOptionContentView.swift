import UIKit

class ChatChoiceOptionContentView: UIView {
    var text: String? {
        get { return textLabel.text }
        set { setText(newValue) }
    }

    private let textLabel = UILabel()
    private let style: ChatTextContentStyle
    private let kInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

    init(with style: ChatTextContentStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = style.backgroundColor
        layer.cornerRadius = 4

        textLabel.font = style.textFont
        textLabel.textColor = style.textColor
        textLabel.numberOfLines = 0
    }

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

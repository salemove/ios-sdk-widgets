import UIKit

class ChatChoiceOptionContentView: UIView {
    var text: String? {
        get { return textLabel.text }
        set { setText(newValue) }
    }
    var isHighlighted: Bool {
        didSet { updateStyle() }
    }
    var onTap: (() -> Void)?

    private let textLabel = UILabel()
    private let choiceButton = UIButton()
    private let style: ChatChoiceOptionContentStyle
    private let kInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

    init(with style: ChatChoiceOptionContentStyle) {
        self.style = style
        self.isHighlighted = false
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
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0

        choiceButton.addTarget(self, action: #selector(onTapped), for: .touchUpInside)
    }

    private func addTextLabelToView() {
        addSubview(textLabel)
        textLabel.autoPinEdgesToSuperviewEdges(with: kInsets)

        addSubview(choiceButton)
        choiceButton.autoPinEdgesToSuperviewEdges()

    }

    private func setText(_ text: String?) {
        if text == nil || text?.isEmpty == true {
            textLabel.removeFromSuperview()
        } else {
            if textLabel.superview == nil {
                addTextLabelToView()
            }
            textLabel.text = text
        }
    }

    private func updateStyle() {
        backgroundColor = isHighlighted ? style.highlightedBackgroundColor : style.backgroundColor
        textLabel.textColor = isHighlighted ? style.highlightedTextColor : style.textColor
    }

    @objc private func onTapped() {
        onTap?()
    }
}

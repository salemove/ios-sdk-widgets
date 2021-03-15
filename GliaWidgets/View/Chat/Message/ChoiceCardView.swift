import UIKit

final class ChoiceCardView: ChatMessageView {
    private let viewStyle: ChoiceCardStyle
    private let kInsets = UIEdgeInsets(top: 8, left: 88, bottom: 8, right: 16)

    init(with style: ChoiceCardStyle) {
        viewStyle = style
        super.init(with: style)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        contentViews.axis = .vertical
        contentViews.spacing = 12
    }

    override func appendContent(_ content: ChatMessageContent, animated: Bool) {
        switch content {
        case .text(let text):
            let contentView = ChatTextContentView(with: style.text)
            contentView.text = text
            appendContentView(contentView, animated: animated)
        case .choiceOptions(let options):
            let contentViews = self.contentViews(for: options)
            appendContentViews(contentViews, animated: animated)
        default:
            break
        }
    }

    private func layout() {
        addSubview(contentViews)
        contentViews.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top)
        contentViews.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right)
        contentViews.autoPinEdge(toSuperviewEdge: .left, withInset: kInsets.left, relation: .greaterThanOrEqual)
    }

    private func contentViews(for options: [ChatChoiceCardOption]) -> [ChatChoiceOptionContentView] {
        return options.compactMap {
            let optionView = ChatChoiceOptionContentView(with: viewStyle.choiceOption)
            optionView.text = $0.text
            return optionView
        }
    }
}

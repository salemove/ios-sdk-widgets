import UIKit

class ReceivedChatMessageView: ChatMessageView {
    private let operatorImageView = UIImageView()
    private let kInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 88)

    override init(with style: ChatMessageStyle) {
        super.init(with: style)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

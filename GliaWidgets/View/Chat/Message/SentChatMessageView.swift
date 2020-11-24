import UIKit

class SentChatMessageView: ChatMessageView {
    private let statusView = ChatMessageStatusView()
    private let kInsets = UIEdgeInsets(top: 5, left: 88, bottom: 5, right: 16)

    override init(with style: ChatMessageStyle) {
        super.init(with: style)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        addSubview(contentViews)
        contentViews.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top)
        contentViews.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right)
        contentViews.autoPinEdge(toSuperviewEdge: .left, withInset: kInsets.left, relation: .greaterThanOrEqual)

        addSubview(statusView)
        statusView.autoPinEdge(.top, to: .bottom, of: contentViews, withOffset: 2)
        statusView.autoPinEdge(toSuperviewEdge: .right)
        statusView.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)
    }
}

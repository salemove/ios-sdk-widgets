import UIKit

final class SystemMessageView: ChatMessageView {
    private let viewStyle: SystemMessageStyle
    private let kInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 96)
    private let kOperatorImageViewSize = CGSize(width: 28, height: 28)
    private let environment: Environment

    init(
        with style: SystemMessageStyle,
        environment: Environment
    ) {
        viewStyle = style
        self.environment = environment
        super.init(
            with: style,
            contentAlignment: .left,
            environment: .init(uiScreen: environment.uiScreen)
        )
        setup()
        layout()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    private func layout() {
        addSubview(contentViews)
        contentViews.autoPinEdge(toSuperviewEdge: .left, withInset: kInsets.left)
        contentViews.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top)
        contentViews.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right, relation: .greaterThanOrEqual)

        NSLayoutConstraint.autoSetPriority(.required) {
            contentViews.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)
        }
    }
}

extension SystemMessageView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

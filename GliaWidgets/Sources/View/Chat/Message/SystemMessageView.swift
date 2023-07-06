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

        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += contentViews.layoutInSuperview(edges: .vertical, insets: kInsets)
        constraints += contentViews.layoutInSuperview(edges: .top, insets: kInsets)
        constraints += contentViews.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: kInsets.right)
    }
}

extension SystemMessageView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

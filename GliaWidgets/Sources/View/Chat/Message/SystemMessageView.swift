import UIKit

final class SystemMessageView: ChatMessageView {
    private let viewStyle: Theme.SystemMessageStyle
    private let kInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 96)
    private let kOperatorImageViewSize = CGSize(width: 28, height: 28)
    private let environment: Environment

    init(
        with style: Theme.SystemMessageStyle,
        environment: Environment
    ) {
        viewStyle = style
        self.environment = environment
        super.init(
            with: .init(
                text: style.text,
                background: style.background,
                imageFile: style.imageFile,
                fileDownload: style.fileDownload,
                accessibility: .init(
                    value: style.accessibility.value,
                    isFontScalingEnabled: style.accessibility.isFontScalingEnabled
                )
            ),
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

        NSLayoutConstraint.activate([
            contentViews.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: kInsets.left),
            contentViews.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -kInsets.right),
            contentViews.topAnchor.constraint(equalTo: self.topAnchor, constant: kInsets.top),
            contentViews.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -kInsets.bottom)
        ])
    }
}

extension SystemMessageView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

import UIKit

class OperatorChatMessageView: ChatMessageView {
    var showsOperatorImage: Bool = false {
        didSet {
            if showsOperatorImage {
                guard operatorImageView == nil else { return }
                let operatorImageView = UserImageView(
                    with: viewStyle.operatorImage,
                    environment: .init(
                        data: environment.data,
                        uuid: environment.uuid,
                        gcd: environment.gcd,
                        imageViewCache: environment.imageViewCache
                    )
                )
                self.operatorImageView = operatorImageView
                operatorImageViewContainer.addSubview(operatorImageView)
                operatorImageView.layoutInSuperview().activate()
            } else {
                operatorImageView?.removeFromSuperview()
                operatorImageView = nil
            }
        }
    }

    private let viewStyle: OperatorChatMessageStyle
    private var operatorImageView: UserImageView?
    private var operatorImageViewContainer = UIView().makeView()
    private let imageViewInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 60)
    private let operatorImageViewSize: CGFloat = 28
    private let environment: Environment

    init(
        with style: OperatorChatMessageStyle,
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

    func setOperatorImage(fromUrl url: String?, animated: Bool) {
        operatorImageView?.setOperatorImage(fromUrl: url, animated: animated)
    }

    private func layout() {
        addSubview(operatorImageViewContainer)
        operatorImageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }

        constraints += operatorImageViewContainer.match(value: operatorImageViewSize)
        constraints += operatorImageViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: imageViewInsets.left)
        constraints += operatorImageViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: imageViewInsets.bottom)
        constraints += operatorImageViewContainer.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: imageViewInsets.top)

        addSubview(contentViews)
        contentViews.translatesAutoresizingMaskIntoConstraints = false
        constraints += contentViews.leadingAnchor.constraint(equalTo: operatorImageViewContainer.trailingAnchor, constant: 8)
        constraints += contentViews.topAnchor.constraint(equalTo: topAnchor, constant: imageViewInsets.top)
        constraints += contentViews.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -imageViewInsets.right)

        constraints += contentViews.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -imageViewInsets.bottom)
    }
}

extension OperatorChatMessageView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var uiScreen: UIKitBased.UIScreen
    }
}

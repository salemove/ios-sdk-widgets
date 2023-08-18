import UIKit

final class GvaResponseTextView: ChatMessageView {
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

    private let viewStyle: Theme.OperatorMessageStyle
    private var operatorImageView: UserImageView?
    private let operatorImageViewContainer = UIView().makeView()
    private let imageViewInsets = UIEdgeInsets(top: 4, left: 8, bottom: 2, right: 60)
    private let operatorImageViewSize: CGFloat = 28
    private let environment: Environment

    init(
        with style: Theme.OperatorMessageStyle,
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

    func setOperatorImage(fromUrl url: String?, animated: Bool) {
        operatorImageView?.setOperatorImage(fromUrl: url, animated: animated)
    }

    private func layout() {
        addSubview(operatorImageViewContainer)
        operatorImageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += operatorImageViewContainer.match(value: operatorImageViewSize)
        constraints += operatorImageViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: imageViewInsets.left)
        constraints += operatorImageViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        constraints += operatorImageViewContainer.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: imageViewInsets.top)

        addSubview(contentViews)
        contentViews.translatesAutoresizingMaskIntoConstraints = false
        constraints += contentViews.leadingAnchor.constraint(equalTo: operatorImageViewContainer.trailingAnchor, constant: 8)
        constraints += contentViews.topAnchor.constraint(equalTo: topAnchor, constant: imageViewInsets.top)
        constraints += contentViews.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -imageViewInsets.right)

        constraints += contentViews.bottomAnchor.constraint(equalTo: bottomAnchor)
    }
}

extension GvaResponseTextView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var uiScreen: UIKitBased.UIScreen
    }
}

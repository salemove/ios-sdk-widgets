import UIKit

final class GvaResponseTextView: ChatMessageView {
    var showsOperatorImage: Bool = false {
        didSet {
            if showsOperatorImage {
                guard operatorImageView == nil else { return }
                let operatorImageView = UserImageView(
                    with: viewStyle.operatorImage,
                    environment: .create(with: environment)
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
    private let imageViewInsets = UIEdgeInsets(top: 8, left: 8, bottom: 2, right: 60)
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
            environment: .create(with: environment)
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
        constraints += operatorImageViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -imageViewInsets.top)
        constraints += operatorImageViewContainer.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: imageViewInsets.top)

        addSubview(contentViews)
        contentViews.translatesAutoresizingMaskIntoConstraints = false
        constraints += contentViews.leadingAnchor.constraint(equalTo: operatorImageViewContainer.trailingAnchor, constant: 8)
        constraints += contentViews.topAnchor.constraint(equalTo: topAnchor, constant: imageViewInsets.top)
        constraints += contentViews.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -imageViewInsets.right)

        constraints += contentViews.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -imageViewInsets.top)
    }
}

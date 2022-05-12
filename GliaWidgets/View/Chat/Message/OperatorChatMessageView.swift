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
                operatorImageView.autoPinEdgesToSuperviewEdges()
            } else {
                operatorImageView?.removeFromSuperview()
                operatorImageView = nil
            }
        }
    }

    private let viewStyle: OperatorChatMessageStyle
    private var operatorImageView: UserImageView?
    private var operatorImageViewContainer = UIView()
    private let kInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 60)
    private let kOperatorImageViewSize = CGSize(width: 28, height: 28)
    private let environment: Environment

    init(
        with style: OperatorChatMessageStyle,
        environment: Environment
    ) {
        viewStyle = style
        self.environment = environment
        super.init(with: style, contentAlignment: .left)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOperatorImage(fromUrl url: String?, animated: Bool) {
        operatorImageView?.setOperatorImage(fromUrl: url, animated: animated)
    }

    private func layout() {
        addSubview(operatorImageViewContainer)
        operatorImageViewContainer.autoSetDimensions(to: kOperatorImageViewSize)
        operatorImageViewContainer.autoPinEdge(toSuperviewEdge: .left, withInset: kInsets.left)
        operatorImageViewContainer.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)
        operatorImageViewContainer.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top, relation: .greaterThanOrEqual)

        addSubview(contentViews)
        contentViews.autoPinEdge(.left, to: .right, of: operatorImageViewContainer, withOffset: 4)
        contentViews.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top)
        contentViews.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right, relation: .greaterThanOrEqual)

        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            contentViews.autoPinEdge(toSuperviewEdge: .bottom, withInset: kInsets.bottom)
        }
    }
}

extension OperatorChatMessageView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
    }
}

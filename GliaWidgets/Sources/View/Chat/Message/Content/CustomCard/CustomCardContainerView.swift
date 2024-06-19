import UIKit

private extension CGFloat {
    static let operatorImageSide: CGFloat = 28
}

final class CustomCardContainerView: BaseView {
    var showsOperatorImage: Bool = false {
        didSet {
            operatorImageView.isHidden = !showsOperatorImage
        }
    }
    var willDisplayView: (() -> Void)?

    private let edgeInsets = UIEdgeInsets(top: 2, left: 44, bottom: 2, right: 60)
    private let operatorImageInsets = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 0)
    private let environment: Environment
    private let style: UserImageStyle
    private lazy var operatorImageView = UserImageView(
        with: style,
        environment: .create(with: environment)
    )

    init(
        style: UserImageStyle,
        environment: Environment
    ) {
        self.style = style
        self.environment = environment
        super.init()
    }

    @available(*, unavailable)
    required init() { fatalError("init() has not been implemented") }

    override func setup() {
        super.setup()

        addSubview(operatorImageView)
        operatorImageView.layoutInSuperview(
            edges: [.bottom, .leading],
            insets: operatorImageInsets
        ).activate()
        operatorImageView.match(
            [.width, .height],
            value: .operatorImageSide
        ).activate()
    }

    // MARK: - Internal

    func addContentView(_ contentView: UIView) {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layoutInSuperview(insets: edgeInsets).activate()
    }

    func setOperatorImage(fromUrl url: String?, animated: Bool) {
        operatorImageView.setOperatorImage(fromUrl: url, animated: animated)
    }
}

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
        environment: .init(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache
        )
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

// MARK: - Environment

extension CustomCardContainerView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
        var uiScreen: UIKitBased.UIScreen
    }
}

#if DEBUG
extension CustomCardContainerView.Environment {
    static func mock(
        data: FoundationBased.Data = .mock,
        uuid: @escaping () -> UUID = { .mock },
        gcd: GCD = .mock,
        imageViewCache: ImageView.Cache = .mock,
        uiScreen: UIKitBased.UIScreen = .mock
    ) -> CustomCardContainerView.Environment {
        .init(
            data: data,
            uuid: uuid,
            gcd: gcd,
            imageViewCache: imageViewCache,
            uiScreen: uiScreen
        )
    }
}
#endif

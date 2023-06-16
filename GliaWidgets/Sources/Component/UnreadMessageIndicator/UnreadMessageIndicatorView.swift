import UIKit

final class UnreadMessageIndicatorView: BaseView {
    var newItemCount: Int = 0 {
        didSet {
            if newItemCount <= 0 {
                isHidden = true
            } else {
                isHidden = false
                badgeView.newItemCount = newItemCount
            }
            updateAccessibilityProperties()
        }
    }

    var tapped: (() -> Void)?

    private let style: UnreadMessageIndicatorStyle

    private let backgroundView = UIImageView()
    private let userImageView: UserImageView
    private let badgeView: BadgeView

    private let kSize = CGSize(width: 58, height: 66) // Shadows included
    private let kUserImageSize = CGSize(width: 36, height: 36)
    private let kBadgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
    private let environment: Environment

    init(
        with style: UnreadMessageIndicatorStyle,
        environment: Environment
    ) {
        self.style = style
        self.environment = environment
        userImageView = UserImageView(
            with: style.userImage,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache
            )
        )
        badgeView = BadgeView(with: style.badge)
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    func setImage(_ image: UIImage?, animated: Bool) {
        userImageView.setOperatorImage(image, animated: animated)
    }

    func setImage(fromUrl url: String?, animated: Bool) {
        userImageView.setOperatorImage(fromUrl: url, animated: animated)
    }

    override func setup() {
        isHidden = true

        backgroundView.image = Asset.unreadMessageIndicator.image
            .withRenderingMode(.alwaysTemplate)
        backgroundView.tintColor = style.indicatorImageTintColor

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(onTap)
        )
        addGestureRecognizer(tapRecognizer)

        isAccessibilityElement = true
        accessibilityTraits = [.button]
    }

    override func defineLayout() {
        super.defineLayout()

        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += match(.width, value: kSize.width)
        constraints += match(.height, value: kSize.height)

        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        constraints += backgroundView.layoutInSuperview()

        addSubview(userImageView)
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        constraints += userImageView.match(.width, value: kUserImageSize.width)
        constraints += userImageView.match(.height, value: kUserImageSize.height)
        constraints += userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 6)
        constraints += userImageView.centerXAnchor.constraint(equalTo: centerXAnchor)

        addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        constraints += badgeView.topAnchor.constraint(equalTo: topAnchor, constant: kBadgeInsets.top)
        constraints += badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kBadgeInsets.right)
    }

    @objc private func onTap() {
        tapped?()
    }

    private func updateAccessibilityProperties() {
        accessibilityLabel = style.accessibility.label
        accessibilityValue = "\(newItemCount)"
        accessibilityIdentifier = "unread_message_indicator"
    }
}

extension UnreadMessageIndicatorView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
    }
}

import UIKit

final class UnreadMessageIndicatorView: View {
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
        setup()
        layout()
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

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(onTap)
        )
        addGestureRecognizer(tapRecognizer)

        isAccessibilityElement = true
        accessibilityTraits = [.button]
    }

    private func layout() {
        autoSetDimensions(to: kSize)

        addSubview(backgroundView)
        backgroundView.autoPinEdgesToSuperviewEdges()

        addSubview(userImageView)
        userImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        userImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 6)
        userImageView.autoSetDimensions(to: kUserImageSize)

        addSubview(badgeView)
        badgeView.autoPinEdge(toSuperviewEdge: .top, withInset: kBadgeInsets.top)
        badgeView.autoPinEdge(toSuperviewEdge: .right, withInset: kBadgeInsets.right)
    }

    @objc private func onTap() {
        tapped?()
    }

    private func updateAccessibilityProperties() {
        accessibilityLabel = "Unread messages"
        accessibilityValue = "\(newItemCount)"
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

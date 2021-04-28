import UIKit

final class NewMessageIndicatorView: View {
    var newItemCount: Int = 0 {
        didSet {
            badgeView.newItemCount = newItemCount
        }
    }

    private let style: NewMessageIndicatorStyle

    private let backgroundView = UIImageView()
    private let userImageView: UserImageView
    private let badgeView: BadgeView

    private let kSize = CGSize(width: 58, height: 66) // Shadows included
    private let kUserImageSize = CGSize(width: 36, height: 36)
    private let kBadgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 4)

    public init(with style: NewMessageIndicatorStyle) {
        self.style = style
        userImageView = UserImageView(with: style.userImage)
        badgeView = BadgeView(with: style.badge)
        super.init()
        setup()
        layout()
    }

    func setImage(_ image: UIImage?, animated: Bool) {
        userImageView.setImage(image, animated: animated)
    }

    func setImage(fromUrl url: String?, animated: Bool) {
        userImageView.setImage(fromUrl: url, animated: animated)
    }

    private func setup() {
        backgroundView.image = Asset.newMessageIndicator.image
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
}

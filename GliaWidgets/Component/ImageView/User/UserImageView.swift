import UIKit

class UserImageView: UIView {
    private let style: UserImageStyle
    private let placeholderImageView = UIImageView()
    private let imageView = UIImageView()
    private let size: CGFloat

    init(with style: UserImageStyle, size: CGFloat) {
        self.style = style
        self.size = size
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ image: UIImage?, animated: Bool) {
        UIView.transition(with: imageView,
                          duration: animated ? 0.2 : 0.0,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.imageView.image = image
                          }, completion: nil)
    }

    private func setup() {
        placeholderImageView.image = style.placeholderImage
        placeholderImageView.tintColor = style.placeholderColor
        placeholderImageView.backgroundColor = style.backgroundColor
        placeholderImageView.clipsToBounds = true
        placeholderImageView.contentMode = .center
        placeholderImageView.layer.cornerRadius = size / 2.0

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = size / 2.0
    }

    private func layout() {
        autoSetDimensions(to: CGSize(width: size, height: size))

        addSubview(placeholderImageView)
        placeholderImageView.autoPinEdgesToSuperviewEdges()

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
    }
}

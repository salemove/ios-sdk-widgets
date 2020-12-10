import UIKit

class UserImageView: UIView {
    private let style: UserImageStyle
    private let placeholderImageView = UIImageView()
    private let imageView = UIImageView()

    init(with style: UserImageStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
        layer.cornerRadius = bounds.height / 2.0
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
        clipsToBounds = true

        placeholderImageView.image = style.placeholderImage
        placeholderImageView.tintColor = style.placeholderColor
        placeholderImageView.backgroundColor = style.backgroundColor
        placeholderImageView.clipsToBounds = true
        placeholderImageView.contentMode = .center

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }

    private func layout() {
        addSubview(placeholderImageView)
        placeholderImageView.autoPinEdgesToSuperviewEdges()

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
    }
}

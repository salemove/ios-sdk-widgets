import UIKit

final class UserImageView: BaseView {
    private let style: UserImageStyle
    private let placeholderInsets: UIEdgeInsets
    private let placeholderImageView = UIImageView()
    private let placeholderBackgroundView = UIView()
    private let operatorImageView: ImageView
    private let environment: Environment

    init(
        with style: UserImageStyle,
        placeholderInsets: UIEdgeInsets = .zero,
        environment: Environment
    ) {
        self.style = style
        self.placeholderInsets = placeholderInsets
        self.environment = environment
        self.operatorImageView = ImageView(environment: .create(with: environment))
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func setup() {
        super.setup()
        clipsToBounds = true

        placeholderImageView.tintColor = style.placeholderColor
        placeholderImageView.image = style.placeholderImage
        updatePlaceholderContentMode()

        operatorImageView.isHidden = true
        operatorImageView.contentMode = .scaleAspectFill
    }

    override func defineLayout() {
        super.defineLayout()

        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }

        addSubview(placeholderBackgroundView)
        placeholderBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        constraints += placeholderBackgroundView.layoutInSuperview()

        addSubview(placeholderImageView)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        constraints += placeholderImageView.layoutInSuperview(insets: placeholderInsets)

        addSubview(operatorImageView)
        operatorImageView.translatesAutoresizingMaskIntoConstraints = false
        constraints += operatorImageView.layoutInSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
        updatePlaceholderContentMode()
        switch style.placeholderBackgroundColor {
        case .fill(let color):
            placeholderBackgroundView.backgroundColor = color
        case .gradient(let colors):
            placeholderBackgroundView.makeGradientBackground(colors: colors)
        }
        switch style.imageBackgroundColor {
        case .fill(let color):
            operatorImageView.backgroundColor = color
        case .gradient(let colors):
            operatorImageView.makeGradientBackground(colors: colors)
        }
    }

    func setPlaceholderImage(_ image: UIImage?) {
        placeholderImageView.image = image
    }

    func setOperatorImage(_ image: UIImage?, animated: Bool) {
        changeOperatorImageVisibility(visible: image != nil)
        operatorImageView.setImage(image, animated: animated)
    }

    func setOperatorImage(fromUrl url: String?, animated: Bool) {
        operatorImageView.setImage(
            from: url,
            animated: animated,
            imageReceived: { [weak self] image in
                self?.changeOperatorImageVisibility(visible: image != nil)
            }
        )
    }

    private func updatePlaceholderContentMode() {
        guard let image = placeholderImageView.image else { return }

        if placeholderImageView.frame.size.width > image.size.width &&
            placeholderImageView.frame.size.height > image.size.height {
            placeholderImageView.contentMode = .center
        } else {
            placeholderImageView.contentMode = .scaleAspectFit
        }
    }

    private func changeOperatorImageVisibility(visible: Bool) {
        placeholderImageView.isHidden = visible
        placeholderBackgroundView.isHidden = visible
        operatorImageView.isHidden = !visible
    }
}

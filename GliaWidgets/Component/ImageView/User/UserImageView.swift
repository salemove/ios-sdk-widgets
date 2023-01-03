import UIKit

final class UserImageView: BaseView {
    private let style: UserImageStyle
    private let placeholderImageView = UIImageView()
    private let operatorImageView: ImageView
    private let environment: Environment

    init(
        with style: UserImageStyle,
        environment: Environment
    ) {
        self.style = style
        self.environment = environment
        self.operatorImageView = ImageView(
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache
            )
        )
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
        addSubview(placeholderImageView)
        addSubview(operatorImageView)
        placeholderImageView.autoPinEdgesToSuperviewEdges()
        operatorImageView.autoPinEdgesToSuperviewEdges()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
        updatePlaceholderContentMode()
        switch style.placeholderBackgroundColor {
        case .fill(let color):
            placeholderImageView.backgroundColor = color
        case .gradient(let colors):
            placeholderImageView.makeGradientBackground(colors: colors)
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
        operatorImageView.isHidden = !visible
    }
}

extension UserImageView {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
    }
}

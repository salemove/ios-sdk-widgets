import UIKit

class ChatOperatorImageView: View {
    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue == nil
                ? style.placeholderImage
                : newValue
        }
    }
    var isAnimating: Bool = false {
        didSet {
            isAnimating
                ? startAnimating()
                : stopAnimating()
        }
    }

    private let style: ChatOperatorImageStyle
    private let imageView = UIImageView()
    private let kImageSize = CGSize(width: 80, height: 80)

    init(with style: ChatOperatorImageStyle) {
        self.style = style
        super.init()
        setup()
        layout()
    }

    private func setup() {
        imageView.image = nil
        imageView.tintColor = style.placeholderColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = kImageSize.width / 2.0
    }

    private func layout() {
        addSubview(imageView)
        imageView.autoSetDimensions(to: kImageSize)
    }

    private func startAnimating() {

    }

    private func stopAnimating() {

    }
}

import UIKit

class ChatMessageUserView: UIView {
    var image: UIImage? {
        get { imageView.image }
        set {
            imageView.image = newValue
            widthConstraint.constant = newValue == nil
                ? 0
                : kSize.width
        }
    }

    private let imageView = UIImageView()
    private var widthConstraint: NSLayoutConstraint!
    private let kSize = CGSize(width: 28, height: 28)

    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = kSize.height / 2.0
    }

    private func layout() {
        autoSetDimension(.height, toSize: kSize.height)
        widthConstraint = autoSetDimension(.width, toSize: 0)

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
    }
}

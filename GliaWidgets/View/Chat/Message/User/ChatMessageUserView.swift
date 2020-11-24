import UIKit

class ChatMessageUserView: UIView {
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    private let imageView = UIImageView()
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
        autoSetDimensions(to: kSize)

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
    }
}

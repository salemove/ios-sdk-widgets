import UIKit
import PureLayout

class ChatMessageStatusView: UIView {
    enum Status {
        case sending
        case delivered

        var image: UIImage? {
            switch self {
            case .sending:
                return nil
            case .delivered:
                return nil
            }
        }
    }

    var status: Status? {
        didSet {
            guard let image = status?.image else {
                heightConstraint.constant = 0
                return
            }

            imageView.image = image
            heightConstraint.constant = kSize.height
        }
    }

    private let imageView = UIImageView()
    private var heightConstraint: NSLayoutConstraint!
    private let kSize = CGSize(width: 15, height: 15)

    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        imageView.contentMode = .scaleAspectFit
    }

    func layout() {
        autoSetDimension(.width, toSize: kSize.width)
        heightConstraint = autoSetDimension(.height, toSize: 0)

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
    }
}

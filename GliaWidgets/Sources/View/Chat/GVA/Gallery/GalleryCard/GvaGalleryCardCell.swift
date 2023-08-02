import UIKit

final class GvaGalleryCardCell: UICollectionViewCell {
    static let identifier = "GvaGalleryCardCell"

    var props: GvaGalleryCardView.Props = .nop {
        didSet {
            renderProps()
        }
    }

    private lazy var cardView = GvaGalleryCardView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp() {
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        cardView.layoutInSuperview(
            edges: [.greaterThanTop, .leading, .trailing, .bottom]
        ).activate()
    }

    func renderProps() {
        cardView.props = props
    }
}

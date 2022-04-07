import UIKit

class ChatImageFileContentView: ChatFileContentView {
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let style: ChatImageFileContentStyle
    private let contentAlignment: ChatMessageContentAlignment
    private let kInsets = UIEdgeInsets.zero
    private let kHeight: CGFloat = 155

    init(with style: ChatImageFileContentStyle,
         content: Content,
         contentAlignment: ChatMessageContentAlignment,
         accessibilityProperties: ChatFileContentView.AccessibilityProperties,
         tap: @escaping () -> Void) {
        self.style = style
        self.contentAlignment = contentAlignment
        super.init(
            with: style,
            content: content,
            accessibilityProperties: accessibilityProperties,
            tap: tap
        )
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        contentView.backgroundColor = style.backgroundColor
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 4

        imageView.contentMode = .scaleAspectFill
    }

    override func layout() {
        super.layout()

        contentView.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()

        addSubview(contentView)
        contentView.autoPinEdge(toSuperviewEdge: .top)
        contentView.autoPinEdge(toSuperviewEdge: .bottom)

        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            contentView.autoSetDimension(.height, toSize: kHeight)
        }

        switch contentAlignment {
        case .left:
            contentView.autoPinEdge(toSuperviewEdge: .left)
            contentView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        case .right:
            contentView.autoPinEdge(toSuperviewEdge: .right)
            contentView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        }
    }

    override func update(with file: LocalFile) {
        setImage(from: file)
    }

    override func update(with download: FileDownload) {
        switch download.state.value {
        case .downloaded(file: let file):
            setImage(from: file)
        default:
            imageView.image = nil
        }
    }

    private func setImage(from file: LocalFile) {
        let size = CGSize(width: 1.5 * kHeight, height: kHeight)
        file.thumbnail(for: size) { image in
            self.setImage(image)
        }
    }

    private func setImage(_ image: UIImage?) {
        imageView.image = image
    }
}

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

    @available(*, unavailable)
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

        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        constraints += imageView.layoutInSuperview()

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        constraints += contentView.layoutInSuperview(edges: .vertical)
        constraints += contentView.match(.height, value: kHeight, priority: .defaultHigh)

        switch contentAlignment {
        case .left:
            constraints += contentView.layoutInSuperview(edges: .leading)
            constraints += contentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        case .right:
            constraints += contentView.layoutInSuperview(edges: .trailing)
            constraints += contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
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

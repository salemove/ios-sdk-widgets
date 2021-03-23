import UIKit

class ChatImageFileContentView: ChatFileContentView {
    private let imageView = UIImageView()
    private let style: ChatImageFileContentStyle
    private let kInsets = UIEdgeInsets.zero
    private let kImageViewSize = CGSize(width: 240, height: 155)

    init(with style: ChatImageFileContentStyle, content: Content, tap: @escaping () -> Void) {
        self.style = style
        super.init(with: style, content: content, tap: tap)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        clipsToBounds = true
        layer.cornerRadius = 4

        imageView.contentMode = .scaleAspectFill
    }

    override func layout() {
        super.layout()

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: kInsets)
        imageView.autoSetDimensions(to: kImageViewSize)
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
        file.thumbnail(for: kImageViewSize) { image in
            self.setImage(image)
        }
    }

    private func setImage(_ image: UIImage?) {
        imageView.image = image
    }
}

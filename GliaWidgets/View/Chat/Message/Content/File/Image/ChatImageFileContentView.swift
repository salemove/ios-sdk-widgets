import UIKit

class ChatImageFileContentView: ChatFileContentView {
    private let imageView = UIImageView()
    private let style: ChatImageFileContentStyle
    private let kInsets = UIEdgeInsets.zero
    private let kSize = CGSize(width: 240, height: 155)

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
        autoSetDimensions(to: kSize)

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: kInsets)
    }

    override func update(with file: LocalFile) {
        setImage(from: file)
    }

    override func update(with download: FileDownload<ChatEngagementFile>) {
        switch download.state.value {
        case .downloaded(file: let file):
            setImage(from: file)
        default:
            imageView.image = nil
        }
    }

    private func setImage(from file: LocalFile) {
        DispatchQueue.global(qos: .background).async {
            let image = UIImage(contentsOfFile: file.url.path)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}

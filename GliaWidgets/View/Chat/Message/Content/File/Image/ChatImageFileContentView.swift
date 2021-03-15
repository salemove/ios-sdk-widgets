import UIKit

class ChatImageFileContentView: ChatFileContentView {
    private let imageView = UIImageView()
    private let style: ChatImageFileContentStyle
    private let kInsets = UIEdgeInsets.zero
    private let kSize = CGSize(width: 240, height: 155)

    init(with style: ChatImageFileContentStyle, content: Content) {
        self.style = style
        super.init(with: style, content: content)
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

    override func update(for file: LocalFile) {
        setImage(from: file.url)
    }

    override func update(for downloadState: FileDownload<ChatEngagementFile>.State) {
        switch downloadState {
        case .downloaded(file: _, url: let url):
            setImage(from: url)
        default:
            imageView.image = nil
        }
    }

    private func setImage(from url: URL) {
        let image = UIImage(contentsOfFile: url.path)
        imageView.image = image
    }
}

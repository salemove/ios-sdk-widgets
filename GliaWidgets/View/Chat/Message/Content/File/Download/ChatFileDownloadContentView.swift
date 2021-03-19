import UIKit

class ChatFileDownloadContentView: ChatFileContentView {
    private let contentView = UIView()
    private let stateLabel = UILabel()
    private let previewImageView: FilePreviewImageView
    private let progressView = UIProgressView()
    private let style: ChatFileDownloadStyle
    private let kContentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let kSize = CGSize(width: 271, height: 68)

    init(with style: ChatFileDownloadStyle, content: Content) {
        self.style = style
        self.previewImageView = FilePreviewImageView(with: style.preview)
        super.init(with: style, content: content)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = style.borderColor.cgColor
    }

    override func layout() {
        super.layout()

        autoSetDimensions(to: kSize)

        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets)
    }

    override func update(for file: LocalFile) {
        
    }

    override func update(for downloadState: FileDownload<ChatEngagementFile>.State) {
        switch downloadState {
        case .none:
            break
        case .downloading(progress: let progress):
            break
        case .downloaded(_):
            break
        case .error(_):
            break
        }
    }
}

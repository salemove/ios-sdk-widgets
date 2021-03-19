import UIKit

class ChatFileDownloadContentView: ChatFileContentView {
    private let contentView = UIView()
    private let infoLabel = UILabel()
    private let stateLabel = UILabel()
    private let previewImageView: FilePreviewImageView
    private let progressView = UIProgressView()
    private let style: ChatFileDownloadStyle
    private let kContentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let kWidth: CGFloat = 271

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

        infoLabel.lineBreakMode = .byTruncatingMiddle

        progressView.backgroundColor = style.progressBackgroundColor
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 4
    }

    override func layout() {
        super.layout()
        autoSetDimension(.width, toSize: kWidth)
        progressView.autoSetDimension(.height, toSize: 8)

        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets)

        contentView.addSubview(previewImageView)
        previewImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .right)

        contentView.addSubview(infoLabel)
        infoLabel.autoPinEdge(.top, to: .top, of: previewImageView, withOffset: 4)
        infoLabel.autoPinEdge(.left, to: .right, of: previewImageView, withOffset: 12)
        infoLabel.autoPinEdge(toSuperviewEdge: .right)

        contentView.addSubview(stateLabel)
        stateLabel.autoPinEdge(.top, to: .bottom, of: infoLabel, withOffset: 4)
        stateLabel.autoPinEdge(.left, to: .right, of: previewImageView, withOffset: 12)
        stateLabel.autoPinEdge(toSuperviewEdge: .right)

        contentView.addSubview(progressView)
        progressView.autoPinEdge(.bottom, to: .bottom, of: previewImageView)
        progressView.autoPinEdge(.left, to: .right, of: previewImageView, withOffset: 12)
        progressView.autoPinEdge(toSuperviewEdge: .right)
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

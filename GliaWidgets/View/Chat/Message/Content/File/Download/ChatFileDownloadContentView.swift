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

    override func update(for file: LocalFile) {
        // this is shown for outgoing messages
        //  - just show file info with no state text
        //  - will turn to Open/Download when message is sent and outgoing message is replaced with visitor message
    }

    override func update(for downloadState: FileDownload<ChatEngagementFile>.State) {
        switch downloadState {
        case .none:
            break
        case .downloading(progress: let progress):
            /*previewImageView.state = .file(.localFile)
            infoLabel.text = fileInfoString(for: upload.localFile)
            infoLabel.numberOfLines = 1
            infoLabel.font = style.uploading.infoFont
            infoLabel.textColor = style.uploading.infoColor
            stateLabel.text = style.uploading.text
            stateLabel.font = style.uploading.font
            stateLabel.textColor = style.uploading.textColor
            progressView.tintColor = style.progressColor
            progressView.progress = Float(progress.value)
            progress.addObserver(self) { progress, _ in
                self.progressView.progress = Float(progress)
            }*/ break
        case .downloaded(_):
            break
        case .error(_):
            break
        }
    }

    private func stateText(for downloadState: FileDownload<ChatEngagementFile>.State) -> NSAttributedString {
        switch downloadState {
        case .none:
            let attributes: [NSAttributedString.Key: Any] = [
                .font: style.download.font,
                .foregroundColor: style.download.textColor
            ]
            return .init(string: style.download.text, attributes: attributes)
        case .downloading:
            let attributes: [NSAttributedString.Key: Any] = [
                .font: style.downloading.font,
                .foregroundColor: style.downloading.textColor
            ]
            return .init(string: style.downloading.text, attributes: attributes)
        case .downloaded:
            let attributes: [NSAttributedString.Key: Any] = [
                .font: style.open.font,
                .foregroundColor: style.open.textColor
            ]
            return .init(string: style.open.text, attributes: attributes)
        case .error:
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: style.error.font,
                .foregroundColor: style.error.textColor
            ]
            let separatorAttributes: [NSAttributedString.Key: Any] = [
                .font: style.error.separatorFont,
                .foregroundColor: style.error.separatorTextColor
            ]
            let retryAttributes: [NSAttributedString.Key: Any] = [
                .font: style.error.retryFont,
                .foregroundColor: style.error.retryTextColor
            ]
            let text = NSAttributedString(
                string: style.error.text,
                attributes: textAttributes
            )
            let separator = NSAttributedString(
                string: style.error.separatorText,
                attributes: separatorAttributes
            )
            let retry = NSAttributedString(
                string: style.error.retryText,
                attributes: retryAttributes
            )
            let string = NSMutableAttributedString()
            string.append(text)
            string.append(separator)
            string.append(retry)
            return string
        }
    }
}

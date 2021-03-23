import UIKit

class ChatFileDownloadContentView: ChatFileContentView {
    private let contentView = UIView()
    private let infoLabel = UILabel()
    private let stateLabel = UILabel()
    private let fileImageView: FileImageView
    private let progressView = UIProgressView()
    private let style: ChatFileDownloadStyle
    private let kContentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let kWidth: CGFloat = 271

    init(with style: ChatFileDownloadStyle, content: Content, tap: @escaping () -> Void) {
        self.style = style
        self.fileImageView = FileImageView(with: style.fileImage)
        super.init(with: style, content: content, tap: tap)
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

        contentView.addSubview(fileImageView)
        fileImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .right)

        contentView.addSubview(infoLabel)
        infoLabel.autoPinEdge(.top, to: .top, of: fileImageView, withOffset: 4)
        infoLabel.autoPinEdge(.left, to: .right, of: fileImageView, withOffset: 12)
        infoLabel.autoPinEdge(toSuperviewEdge: .right)

        contentView.addSubview(stateLabel)
        stateLabel.autoPinEdge(.top, to: .bottom, of: infoLabel, withOffset: 4)
        stateLabel.autoPinEdge(.left, to: .right, of: fileImageView, withOffset: 12)
        stateLabel.autoPinEdge(toSuperviewEdge: .right)

        contentView.addSubview(progressView)
        progressView.autoPinEdge(.bottom, to: .bottom, of: fileImageView)
        progressView.autoPinEdge(.left, to: .right, of: fileImageView, withOffset: 12)
        progressView.autoPinEdge(toSuperviewEdge: .right)
    }

    override func update(with file: LocalFile) {
        fileImageView.kind = .file(file)
        infoLabel.text = file.fileInfoString
        infoLabel.font = style.open.infoFont
        infoLabel.textColor = style.open.infoColor
        stateLabel.text = style.open.text
        stateLabel.font = style.open.font
        stateLabel.textColor = style.open.textColor
        progressView.isHidden = true
    }

    override func update(with download: FileDownload) {
        switch download.state.value {
        case .none:
            fileImageView.kind = .fileExtension(download.file.fileExtension)
            infoLabel.text = download.file.fileInfoString
            infoLabel.font = style.download.infoFont
            infoLabel.textColor = style.download.infoColor
            stateLabel.attributedText = stateText(for: download.state.value)
            progressView.isHidden = true
        case .downloading(progress: let progress):
            fileImageView.kind = .fileExtension(download.file.fileExtension)
            infoLabel.text = download.file.fileInfoString
            infoLabel.font = style.downloading.infoFont
            infoLabel.textColor = style.downloading.infoColor
            stateLabel.attributedText = stateText(for: download.state.value)
            progressView.tintColor = style.progressColor
            progressView.progress = Float(progress.value)
            progressView.isHidden = false
            progress.addObserver(self) { progress, _ in
                self.progressView.progress = Float(progress)
            }
        case .downloaded(let file):
            fileImageView.kind = .file(file)
            infoLabel.text = download.file.fileInfoString
            infoLabel.font = style.open.infoFont
            infoLabel.textColor = style.open.infoColor
            stateLabel.attributedText = stateText(for: download.state.value)
            progressView.isHidden = true
        case .error:
            fileImageView.kind = .error
            infoLabel.text = download.file.fileInfoString
            infoLabel.font = style.error.infoFont
            infoLabel.textColor = style.error.infoColor
            stateLabel.attributedText = stateText(for: download.state.value)
            progressView.isHidden = false
            progressView.tintColor = style.errorProgressColor
            progressView.progress = 1.0
        }
    }

    private func stateText(for downloadState: FileDownload.State) -> NSAttributedString? {
        switch downloadState {
        case .none:
            return .init(
                string: style.download.text,
                attributes: [
                    .font: style.download.font,
                    .foregroundColor: style.download.textColor
                ]
            )
        case .downloading:
            return .init(
                string: style.downloading.text,
                attributes: [
                    .font: style.downloading.font,
                    .foregroundColor: style.downloading.textColor
                ]
            )
        case .downloaded:
            return .init(
                string: style.open.text,
                attributes: [
                    .font: style.open.font,
                    .foregroundColor: style.open.textColor
                ]
            )
        case .error:
            let text = NSAttributedString(
                string: style.error.text,
                attributes: [
                    .font: style.error.font,
                    .foregroundColor: style.error.textColor
                ]
            )
            let separator = NSAttributedString(
                string: style.error.separatorText,
                attributes: [
                    .font: style.error.separatorFont,
                    .foregroundColor: style.error.separatorTextColor
                ]
            )
            let retry = NSAttributedString(
                string: style.error.retryText,
                attributes: [
                    .font: style.error.retryFont,
                    .foregroundColor: style.error.retryTextColor
                ]
            )
            let string = NSMutableAttributedString()
            string.append(text)
            string.append(separator)
            string.append(retry)
            return string
        }
    }
}

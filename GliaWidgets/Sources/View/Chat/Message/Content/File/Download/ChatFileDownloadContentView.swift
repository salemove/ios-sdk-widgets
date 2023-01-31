import UIKit

class ChatFileDownloadContentView: ChatFileContentView {
    private let contentView = UIView()
    private let infoLabel = UILabel()
    private let stateLabel = UILabel()
    private let filePreviewView: FilePreviewView
    private let progressView = UIProgressView()
    private let style: ChatFileDownloadStyle
    private let kContentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    init(
        with style: ChatFileDownloadStyle,
        content: Content,
        accessibilityProperties: ChatFileContentView.AccessibilityProperties,
        tap: @escaping () -> Void
    ) {
        self.style = style
        self.filePreviewView = FilePreviewView(with: style.filePreview)
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
        backgroundColor = style.backgroundColor
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = style.borderColor.cgColor

        infoLabel.lineBreakMode = .byTruncatingMiddle
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: infoLabel
        )

        progressView.backgroundColor = style.progressBackgroundColor
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 4
    }

    override func layout() {
        super.layout()
        progressView.autoSetDimension(.height, toSize: 8)

        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets)

        contentView.addSubview(filePreviewView)
        filePreviewView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .right)

        contentView.addSubview(infoLabel)
        infoLabel.autoPinEdge(.top, to: .top, of: filePreviewView, withOffset: 4)
        infoLabel.autoPinEdge(.left, to: .right, of: filePreviewView, withOffset: 12)
        infoLabel.autoPinEdge(toSuperviewEdge: .right)

        contentView.addSubview(stateLabel)
        stateLabel.autoPinEdge(.top, to: .bottom, of: infoLabel, withOffset: 4)
        stateLabel.autoPinEdge(.left, to: .right, of: filePreviewView, withOffset: 12)
        stateLabel.autoPinEdge(toSuperviewEdge: .right)

        contentView.addSubview(progressView)
        progressView.autoPinEdge(.bottom, to: .bottom, of: filePreviewView)
        progressView.autoPinEdge(.left, to: .right, of: filePreviewView, withOffset: 12)
        progressView.autoPinEdge(toSuperviewEdge: .right)
    }

    override func update(with file: LocalFile) {
        filePreviewView.kind = .file(file)
        infoLabel.text = file.fileInfoString
        infoLabel.font = style.open.infoFont
        infoLabel.textColor = style.open.infoColor
        stateLabel.text = style.open.text
        stateLabel.font = style.open.font
        stateLabel.textColor = style.open.textColor
        progressView.isHidden = true
    }

    // swiftlint:disable function_body_length
    override func update(with download: FileDownload) {
        let sharedProperties = super.sharedAccessibility()
        switch download.state.value {
        case .none:
            filePreviewView.kind = .fileExtension(download.file.fileExtension)
            infoLabel.text = download.file.fileInfoString
            infoLabel.font = style.download.infoFont
            infoLabel.textColor = style.download.infoColor
            stateLabel.attributedText = stateText(for: download.state.value)
            progressView.isHidden = true

            if let infoText = infoLabel.attributedText?.string, let stateText = stateLabel.attributedText?.string {
                accessibilityValue = style.stateAccessibility.noneState
                    .withDownloadedFileName(infoText)
                    .withDownloadedFileState(stateText)
            } else {
                accessibilityValue = sharedProperties.value
            }

        case .downloading(progress: let progress):
            filePreviewView.kind = .fileExtension(download.file.fileExtension)
            infoLabel.text = download.file.fileInfoString
            infoLabel.font = style.downloading.infoFont
            infoLabel.textColor = style.downloading.infoColor
            stateLabel.attributedText = stateText(for: download.state.value)
            progressView.tintColor = style.progressColor
            progressView.progress = Float(progress.value)
            progressView.isHidden = false

            let percentValue: (Double) -> String = { String(Int($0 * 100)) }
            let downloadingStateFormat = style.stateAccessibility.downloadingState
            if let infoText = infoLabel.attributedText?.string, let stateText = stateLabel.attributedText?.string {
                accessibilityValue = downloadingStateFormat
                    .withDownloadedFileName(infoText)
                    .withDownloadedFileState(stateText)
                    .withDownloadPercentValue(percentValue(progress.value))
            } else {
                accessibilityValue = sharedProperties.value
            }

            progress.addObserver(self) { [weak self] progress, _ in
                self?.progressView.progress = Float(progress)
                if let infoText = self?.infoLabel.attributedText?.string, let stateText = self?.stateLabel.attributedText?.string {
                    self?.accessibilityValue = downloadingStateFormat
                        .withDownloadedFileName(infoText)
                        .withDownloadedFileState(stateText)
                        .withDownloadPercentValue(percentValue(progress))
                } else {
                    self?.accessibilityValue = sharedProperties.value
                }
            }
        case .downloaded(let file):
            filePreviewView.kind = .file(file)
            infoLabel.text = download.file.fileInfoString
            infoLabel.font = style.open.infoFont
            infoLabel.textColor = style.open.infoColor
            stateLabel.attributedText = stateText(for: download.state.value)
            progressView.isHidden = true

            if let infoText = infoLabel.attributedText?.string, let stateText = stateLabel.attributedText?.string {
                accessibilityValue = style.stateAccessibility.downloadedState
                    .withDownloadedFileName(infoText)
                    .withDownloadedFileState(stateText)
            } else {
                accessibilityValue = sharedProperties.value
            }

        case .error:
            filePreviewView.kind = .error
            infoLabel.text = download.file.fileInfoString
            infoLabel.font = style.error.infoFont
            infoLabel.textColor = style.error.infoColor
            stateLabel.attributedText = stateText(for: download.state.value)
            progressView.isHidden = false
            progressView.tintColor = style.errorProgressColor
            progressView.progress = 1.0

            if let infoText = infoLabel.attributedText?.string, let stateText = stateLabel.attributedText?.string {
                accessibilityValue = style.stateAccessibility.errorState
                    .withDownloadedFileName(infoText)
                    .withDownloadedFileState(stateText)
            } else {
                accessibilityValue = sharedProperties.value
            }
        }
        accessibilityLabel = sharedProperties.label
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
    // swiftlint:enable function_body_length
}

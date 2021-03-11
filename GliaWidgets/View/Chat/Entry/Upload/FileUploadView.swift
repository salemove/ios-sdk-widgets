import UIKit

class FileUploadView: UIView {
    enum State {
        case none
        case uploading(url: URL, progress: ValueProvider<Double>)
        case uploaded(url: URL)
        case error(Error)
    }

    enum Error {
        case fileTooBig
        case unsupportedFileType
        case safetyCheckFailed
        case network
        case generic

        func infoText(from style: FileUploadErrorStateStyle) -> String? {
            switch self {
            case .fileTooBig:
                return style.infoFileTooBig
            case .unsupportedFileType:
                return style.infoUnsupportedFileType
            case .safetyCheckFailed:
                return style.infoSafetyCheckFailed
            case .network:
                return style.infoNetworkError
            case .generic:
                return style.infoGenericError
            }
        }
    }

    var removeTapped: (() -> Void)?

    static let height: CGFloat = 60

    private let contentView = UIView()
    private let infoLabel = UILabel()
    private let stateLabel = UILabel()
    private let previewImageView: FilePreviewImageView
    private let progressView = UIProgressView()
    private let removeButton = UIButton()
    private let style: FileUploadStyle
    private let state: ValueProvider<State>
    private let kContentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    init(with style: FileUploadStyle, state: ValueProvider<State>) {
        self.style = style
        self.state = state
        self.previewImageView = FilePreviewImageView(with: style.preview)
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        infoLabel.lineBreakMode = .byTruncatingMiddle

        progressView.backgroundColor = style.progressBackgroundColor
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 4

        removeButton.tintColor = style.removeButtonColor
        removeButton.setImage(style.removeButtonImage, for: .normal)
        removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)

        update(for: state.value)
        state.addObserver(self) { state, _ in
            self.update(for: state)
        }
    }

    private func layout() {
        autoSetDimension(.height, toSize: FileUploadView.height)
        progressView.autoSetDimension(.height, toSize: 8)

        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets)

        contentView.addSubview(previewImageView)
        previewImageView.autoPinEdge(toSuperviewEdge: .left)
        previewImageView.autoAlignAxis(toSuperviewAxis: .horizontal)

        contentView.addSubview(removeButton)
        removeButton.autoSetDimensions(to: CGSize(width: 30, height: 30))
        removeButton.autoPinEdge(toSuperviewEdge: .top)
        removeButton.autoPinEdge(toSuperviewEdge: .right)

        contentView.addSubview(infoLabel)
        infoLabel.autoPinEdge(.top, to: .top, of: previewImageView, withOffset: 4)
        infoLabel.autoPinEdge(.left, to: .right, of: previewImageView, withOffset: 12)
        infoLabel.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)

        contentView.addSubview(stateLabel)
        stateLabel.autoPinEdge(.top, to: .bottom, of: infoLabel, withOffset: 4)
        stateLabel.autoPinEdge(.left, to: .right, of: previewImageView, withOffset: 12)
        stateLabel.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)

        contentView.addSubview(progressView)
        progressView.autoPinEdge(.bottom, to: .bottom, of: previewImageView)
        progressView.autoPinEdge(.left, to: .right, of: previewImageView, withOffset: 12)
        progressView.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)
    }

    private func update(for state: State) {
        switch state {
        case .none:
            previewImageView.state = .none
            infoLabel.text = nil
            stateLabel.text = nil
        case .uploading(url: let url, progress: let progress):
            previewImageView.state = .file(url: url)
            infoLabel.text = fileInfoString(for: url)
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
            }
        case .uploaded(url: let url):
            previewImageView.state = .file(url: url)
            infoLabel.text = fileInfoString(for: url)
            infoLabel.numberOfLines = 1
            infoLabel.font = style.uploaded.infoFont
            infoLabel.textColor = style.uploaded.infoColor
            stateLabel.text = style.uploaded.text
            stateLabel.font = style.uploaded.font
            stateLabel.textColor = style.uploaded.textColor
            progressView.tintColor = style.progressColor
            progressView.progress = 1.0
        case .error(let error):
            previewImageView.state = .error
            infoLabel.text = error.infoText(from: style.error)
            infoLabel.numberOfLines = 2
            infoLabel.font = style.error.infoFont
            infoLabel.textColor = style.error.infoColor
            stateLabel.text = style.error.text
            stateLabel.font = style.error.font
            stateLabel.textColor = style.error.textColor
            progressView.tintColor = style.errorProgressColor
            progressView.progress = 1.0
        }
    }

    private func fileInfoString(for url: URL) -> String? {
        let fileName = url.fileName
        let fileSize = url.fileSizeString

        if let fileName = fileName, let fileSize = fileSize {
            return "\(fileName) • \(fileSize)"
        } else if let fileName = fileName {
            return fileName
        } else if let fileSize = fileSize {
            return fileSize
        } else {
            return nil
        }
    }

    @objc private func remove() {
        removeTapped?()
    }
}

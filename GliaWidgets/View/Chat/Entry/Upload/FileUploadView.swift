import UIKit

class FileUploadView: UIView {
    enum State {
        case none
        case uploading(url: URL, progress: ValueProvider<Float>)
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

    var state: State = .none {
        didSet { update(for: state) }
    }
    var cancelTapped: (() -> Void)?

    static let height: CGFloat = 60

    private let contentView = UIView()
    private let infoLabel = UILabel()
    private let stateLabel = UILabel()
    private let previewImageView: FilePreviewImageView
    private let progressView = UIProgressView()
    private let cancelButton = UIButton()
    private let style: FileUploadStyle
    private let kContentInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

    init(with style: FileUploadStyle) {
        self.style = style
        self.previewImageView = FilePreviewImageView(with: style.preview)
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.layer.cornerRadius = 4
    }

    private func setup() {
        progressView.tintColor = style.progressColor
        progressView.backgroundColor = style.progressBackgroundColor

        cancelButton.tintColor = style.cancelButtonColor
        cancelButton.setImage(style.cancelButtonImage, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    }

    private func layout() {
        autoSetDimension(.height, toSize: FileUploadView.height)
        progressView.autoSetDimension(.height, toSize: 8)

        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets)

        contentView.addSubview(previewImageView)
        previewImageView.autoPinEdge(toSuperviewEdge: .left)
        previewImageView.autoAlignAxis(toSuperviewAxis: .horizontal)

        contentView.addSubview(cancelButton)
        cancelButton.autoSetDimensions(to: CGSize(width: 30, height: 30))
        cancelButton.autoPinEdge(toSuperviewEdge: .top)
        cancelButton.autoPinEdge(toSuperviewEdge: .right)

        contentView.addSubview(infoLabel)
        infoLabel.autoPinEdge(.top, to: .top, of: previewImageView, withOffset: -4)
        infoLabel.autoPinEdge(.left, to: .right, of: previewImageView, withOffset: 12)
        infoLabel.autoPinEdge(.right, to: .left, of: cancelButton, withOffset: 12)

        contentView.addSubview(stateLabel)
        stateLabel.autoPinEdge(.top, to: .top, of: infoLabel, withOffset: 4)
        stateLabel.autoPinEdge(.left, to: .right, of: previewImageView, withOffset: 12)
        stateLabel.autoPinEdge(.right, to: .left, of: cancelButton, withOffset: 12)

        contentView.addSubview(progressView)
        progressView.autoPinEdge(.bottom, to: .bottom, of: previewImageView)
        progressView.autoPinEdge(.left, to: .right, of: previewImageView, withOffset: 12)
        progressView.autoPinEdge(.right, to: .left, of: cancelButton, withOffset: 12)
    }

    private func update(for state: State) {
        switch state {
        case .none:
            previewImageView.state = .none
            infoLabel.text = nil
            stateLabel.text = nil
            progressView.isHidden = true
        case .uploading(url: let url, progress: let progress):
            previewImageView.state = .file(url: url)
            infoLabel.text = nil //TODO filename, size
            infoLabel.font = style.uploading.infoFont
            infoLabel.textColor = style.uploading.infoColor
            stateLabel.text = style.uploading.text
            stateLabel.font = style.uploading.font
            stateLabel.textColor = style.uploading.textColor
            progressView.isHidden = false
            progress.addObserver(self) { progress, _ in
                self.progressView.progress = progress
            }
        case .uploaded(url: let url):
            previewImageView.state = .file(url: url)
            infoLabel.text = nil //TODO filename, size
            infoLabel.font = style.uploaded.infoFont
            infoLabel.textColor = style.uploaded.infoColor
            stateLabel.text = style.uploaded.text
            stateLabel.font = style.uploaded.font
            stateLabel.textColor = style.uploaded.textColor
            progressView.isHidden = false
            progressView.progress = 1.0
        case .error(let error):
            previewImageView.state = .error
            infoLabel.text = error.infoText(from: style.error)
            infoLabel.font = style.error.infoFont
            infoLabel.textColor = style.error.infoColor
            stateLabel.text = style.error.text
            stateLabel.font = style.error.font
            stateLabel.textColor = style.error.textColor
            progressView.isHidden = true
        }
    }

    @objc private func cancel() {
        cancelTapped?()
    }
}

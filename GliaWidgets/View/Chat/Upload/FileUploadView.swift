import UIKit

class FileUploadView: UIView {
    enum State {
        case none
        case uploading(url: URL, progress: ValueProvider<Float>)
        case uploaded(url: URL)
        case error(Error)
    }

    enum Error {
        case fileSizeOverLimit
        case invalidFileType
        case safetyCheckFailed

        func infoText(from style: FileUploadErrorStateStyle) -> String? {
            switch self {
            case .fileSizeOverLimit:
                return style.infoFileSizeOverLimit
            case .invalidFileType:
                return style.infoInvalidFileType
            case .safetyCheckFailed:
                return style.infoSafetyCheckFailed
            }
        }
    }

    var state: State = .none {
        didSet { update(for: state) }
    }
    var cancelTapped: (() -> Void)?

    let height: CGFloat = 60

    private let infoLabel = UILabel()
    private let stateLabel = UILabel()
    private let previewImageView: FilePreviewImageView
    private let progressView = UIProgressView()
    private let cancelButton = UIButton()
    private let stackView = UIStackView()
    private let style: FileUploadStyle

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

        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.addArrangedSubviews([infoLabel, stateLabel, progressView])
    }

    private func layout() {
        autoSetDimension(.height, toSize: height)

        progressView.autoSetDimension(.height, toSize: 8)

        addSubview(previewImageView)
        previewImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        previewImageView.autoAlignAxis(toSuperviewAxis: .horizontal)

        addSubview(cancelButton)
        cancelButton.autoSetDimensions(to: CGSize(width: 30, height: 30))
        cancelButton.autoPinEdge(toSuperviewEdge: .top)
        cancelButton.autoPinEdge(toSuperviewEdge: .right)

        addSubview(stackView)
        stackView.autoPinEdge(.left, to: .right, of: previewImageView, withOffset: 12)
        stackView.autoPinEdge(.right, to: .left, of: cancelButton, withOffset: 12)
        stackView.autoMatch(.height, to: .height, of: previewImageView)
        stackView.autoAlignAxis(toSuperviewAxis: .horizontal)
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

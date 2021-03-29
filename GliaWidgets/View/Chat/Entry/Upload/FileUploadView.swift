import UIKit

class FileUploadView: UIView {
    let upload: FileUpload
    var removeTapped: (() -> Void)?

    static let height: CGFloat = 60

    private let contentView = UIView()
    private let infoLabel = UILabel()
    private let stateLabel = UILabel()
    private let fileImageView: FileImageView
    private let progressView = UIProgressView()
    private let removeButton = UIButton()
    private let style: FileUploadStyle
    private let kContentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    init(with style: FileUploadStyle, upload: FileUpload) {
        self.style = style
        self.upload = upload
        self.fileImageView = FileImageView(with: style.fileImage)
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

        update(for: upload.state.value)
        upload.state.addObserver(self) { state, _ in
            self.update(for: state)
        }
    }

    private func layout() {
        autoSetDimension(.height, toSize: FileUploadView.height)
        progressView.autoSetDimension(.height, toSize: 8)

        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets)

        contentView.addSubview(fileImageView)
        fileImageView.autoPinEdge(toSuperviewEdge: .left)
        fileImageView.autoAlignAxis(toSuperviewAxis: .horizontal)

        contentView.addSubview(removeButton)
        removeButton.autoSetDimensions(to: CGSize(width: 30, height: 30))
        removeButton.autoPinEdge(toSuperviewEdge: .top)
        removeButton.autoPinEdge(toSuperviewEdge: .right)

        contentView.addSubview(infoLabel)
        infoLabel.autoPinEdge(.top, to: .top, of: fileImageView, withOffset: 4)
        infoLabel.autoPinEdge(.left, to: .right, of: fileImageView, withOffset: 12)
        infoLabel.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)

        contentView.addSubview(stateLabel)
        stateLabel.autoPinEdge(.top, to: .bottom, of: infoLabel, withOffset: 4)
        stateLabel.autoPinEdge(.left, to: .right, of: fileImageView, withOffset: 12)
        stateLabel.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)

        contentView.addSubview(progressView)
        progressView.autoPinEdge(.bottom, to: .bottom, of: fileImageView)
        progressView.autoPinEdge(.left, to: .right, of: fileImageView, withOffset: 12)
        progressView.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)
    }

    private func update(for state: FileUpload.State) {
        switch state {
        case .none:
            fileImageView.kind = .none
            infoLabel.text = nil
            stateLabel.text = nil
        case .uploading(progress: let progress):
            fileImageView.kind = .file(upload.localFile)
            infoLabel.text = upload.localFile.fileInfoString
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
        case .uploaded:
            fileImageView.kind = .file(upload.localFile)
            infoLabel.text = upload.localFile.fileInfoString
            infoLabel.numberOfLines = 1
            infoLabel.font = style.uploaded.infoFont
            infoLabel.textColor = style.uploaded.infoColor
            stateLabel.text = style.uploaded.text
            stateLabel.font = style.uploaded.font
            stateLabel.textColor = style.uploaded.textColor
            progressView.tintColor = style.progressColor
            progressView.progress = 1.0
        case .error(let error):
            fileImageView.kind = .error
            infoLabel.text = errorText(from: style.error, for: error)
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

    private func errorText(from style: FileUploadErrorStateStyle, for error: FileUpload.Error) -> String {
        switch error {
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

    @objc private func remove() {
        removeTapped?()
    }
}

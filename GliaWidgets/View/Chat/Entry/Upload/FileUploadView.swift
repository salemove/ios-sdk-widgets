import UIKit

class FileUploadView: UIView {
    let upload: FileUpload
    var removeTapped: (() -> Void)?

    static let height: CGFloat = 60

    private let contentView = UIView()
    private let infoLabel = UILabel()
    private let stateLabel = UILabel()
    private let filePreviewView: FilePreviewView
    private let progressView = UIProgressView()
    let removeButton = UIButton()
    private let style: FileUploadStyle
    private let kContentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private let kRemoveButtonSize = CGSize(width: 30, height: 30)

    init(with style: FileUploadStyle, upload: FileUpload) {
        self.style = style
        self.upload = upload
        self.filePreviewView = FilePreviewView(with: style.filePreview)
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
        upload.state.addObserver(self) { [weak self] state, _ in
            self?.update(for: state)
        }
        removeButton.accessibilityLabel = style.accessibility.removeButtonAccessibilityLabel
        isAccessibilityElement = true

        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: infoLabel
        )
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: stateLabel
        )
    }

    private func layout() {
        autoSetDimension(.height, toSize: FileUploadView.height)
        progressView.autoSetDimension(.height, toSize: 8)

        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets)

        contentView.addSubview(filePreviewView)
        filePreviewView.autoPinEdge(toSuperviewEdge: .left)
        filePreviewView.autoAlignAxis(toSuperviewAxis: .horizontal)

        contentView.addSubview(removeButton)
        removeButton.autoSetDimensions(to: kRemoveButtonSize)
        removeButton.autoPinEdge(toSuperviewEdge: .top)
        removeButton.autoPinEdge(toSuperviewEdge: .right)

        contentView.addSubview(infoLabel)
        infoLabel.autoPinEdge(.top, to: .top, of: contentView, withOffset: -2)
        infoLabel.autoPinEdge(.left, to: .right, of: filePreviewView, withOffset: 12)
        infoLabel.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)

        contentView.addSubview(stateLabel)
        stateLabel.autoPinEdge(.top, to: .bottom, of: infoLabel, withOffset: 4)
        stateLabel.autoPinEdge(.left, to: .right, of: filePreviewView, withOffset: 12)
        stateLabel.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)

        contentView.addSubview(progressView)
        progressView.autoPinEdge(.bottom, to: .bottom, of: filePreviewView)
        progressView.autoPinEdge(.left, to: .right, of: filePreviewView, withOffset: 12)
        progressView.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)
    }

    // swiftlint:disable function_body_length
    private func update(for state: FileUpload.State) {
        switch state {
        case .none:
            filePreviewView.kind = .none
            infoLabel.text = nil
            stateLabel.text = nil
            accessibilityValue = nil
        case .uploading(progress: let progress):
            filePreviewView.kind = .file(upload.localFile)
            infoLabel.text = upload.localFile.fileInfoString
            infoLabel.numberOfLines = 1
            infoLabel.font = style.uploading.infoFont
            infoLabel.textColor = style.uploading.infoColor
            stateLabel.text = style.uploading.text
            stateLabel.font = style.uploading.font
            stateLabel.textColor = style.uploading.textColor
            progressView.tintColor = style.progressColor
            progressView.progress = Float(progress.value)
            let provideProgressText: (Double) -> String = { "\(Int($0 * 100))" }
            accessibilityValue = Self.accessibleProgress(
                provideProgressText(progress.value),
                to: infoLabel.text,
                accessibility: style.accessibility
            )

            progress.addObserver(self) { [weak self, accessibility = style.accessibility] progress, _ in
                self?.progressView.progress = Float(progress)
                self?.accessibilityValue = Self.accessibleProgress(
                    provideProgressText(progress),
                    to: self?.infoLabel.text,
                    accessibility: accessibility
                )
            }
        case .uploaded:
            filePreviewView.kind = .file(upload.localFile)
            infoLabel.text = upload.localFile.fileInfoString
            infoLabel.numberOfLines = 1
            infoLabel.font = style.uploaded.infoFont
            infoLabel.textColor = style.uploaded.infoColor
            stateLabel.text = style.uploaded.text
            stateLabel.font = style.uploaded.font
            stateLabel.textColor = style.uploaded.textColor
            progressView.tintColor = style.progressColor
            progressView.progress = 1.0
            accessibilityValue = Self.accessibleProgress(
                "100",
                to: infoLabel.text,
                accessibility: style.accessibility
            )
        case .error(let error):
            filePreviewView.kind = .error
            infoLabel.text = errorText(from: style.error, for: error)
            infoLabel.numberOfLines = 2
            infoLabel.font = style.error.infoFont
            infoLabel.textColor = style.error.infoColor
            stateLabel.text = style.error.text
            stateLabel.font = style.error.font
            stateLabel.textColor = style.error.textColor
            progressView.tintColor = style.errorProgressColor
            progressView.progress = 1.0
            accessibilityValue = infoLabel.text
        }
        accessibilityLabel = stateLabel.text
    }
    // swiftlint:enable function_body_length

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

    override func layoutSubviews() {
        super.layoutSubviews()
        // Make FileUploadView `accessibilityFrame` smaller
        // to allow VoiceOver to "see" `removeButton`
        var accFrame = self.frame
        let insetX = kContentInsets.left + kContentInsets.right + kRemoveButtonSize.width
        accFrame.size.width -= insetX
        accessibilityFrame = UIAccessibility.convertToScreenCoordinates(accFrame, in: self)
    }

    static func accessibleProgress(_ progress: String, to source: String?, accessibility: FileUploadStyle.Accessibility) -> String? {
        // treat empty progress string as if it is `nil`
        let nonEmptyProgress = progress.isEmpty ? nil : progress
        switch (nonEmptyProgress, source) {
        case (.none, .none):
            return nil
        case let (.some(percentValue), .some(fileName)):
            return accessibility.fileNameWithProgressValue
                .withUploadedFileName(fileName)
                .withUploadPercentValue(percentValue)
        case let (.none, .some(percentValue)):
            return accessibility.progressPercentValue.withUploadPercentValue(percentValue)
        case let (.some(fileName), .none):
            return fileName
        }
    }
}

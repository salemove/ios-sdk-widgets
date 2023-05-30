import UIKit

extension SecureConversations {
    final class FileUploadView: UIView {
        typealias FileUpload = Props

        struct Props: Equatable, Identifiying {
            typealias Identifier = String
            let id: Identifier
            let style: Style
            let state: State
            let removeTapped: Cmd
        }

        static func height(for style: Style) -> CGFloat {
            switch style {
            case .chat:
                return 60
            case .messageCenter:
                return 80
            }
        }

        private let contentView = UIView()
        private let infoLabel = UILabel()
        private let stateLabel = UILabel()
        private let filePreviewView: FilePreviewView
        private let progressView = UIProgressView()
        let removeButton = UIButton()

        private let kRemoveButtonSize = CGSize(width: 30, height: 30)

        var props: Props {
            didSet {
                renderProps()
            }
        }

        init(props: Props, environment: Environment) {
            filePreviewView = .init(environment: .init(uiScreen: environment.uiScreen))
            self.props = props
            super.init(frame: .zero)
            setup()
            layout()
            renderProps()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup() {
            infoLabel.lineBreakMode = .byTruncatingMiddle
            stateLabel.adjustsFontSizeToFitWidth = true

            progressView.clipsToBounds = true
            progressView.layer.cornerRadius = 4

            removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
            removeButton.accessibilityIdentifier = "secureConversations_remove_attachment_button"
            isAccessibilityElement = true
        }

        private func layout() {
            autoSetDimension(
                .height,
                toSize: Self.height(for: props.style),
                relation: .greaterThanOrEqual
            )
            progressView.autoSetDimension(.height, toSize: 8)

            addSubview(contentView)
            let style = Style.Properties(style: props.style)
            contentView.autoPinEdgesToSuperviewEdges(with: style.contentInsets)

            contentView.addSubview(filePreviewView)
            filePreviewView.autoPinEdge(toSuperviewEdge: .left)
            filePreviewView.autoAlignAxis(toSuperviewAxis: .horizontal)

            contentView.addSubview(removeButton)
            removeButton.autoSetDimensions(to: kRemoveButtonSize)
            removeButton.autoPinEdge(
                toSuperviewEdge: .top,
                withInset: style.removeButtonTopRightOffset.height
            )
            removeButton.autoPinEdge(
                toSuperviewEdge: .right,
                withInset: style.removeButtonTopRightOffset.width
            )
            contentView.addSubview(infoLabel)
            infoLabel.autoPinEdge(.top, to: .top, of: contentView, withOffset: -6)
            infoLabel.autoPinEdge(.left, to: .right, of: filePreviewView, withOffset: 12)
            infoLabel.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)

            contentView.addSubview(stateLabel)
            stateLabel.autoPinEdge(.top, to: .bottom, of: infoLabel, withOffset: 4)
            stateLabel.autoPinEdge(.left, to: .right, of: filePreviewView, withOffset: 12)
            stateLabel.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)

            contentView.addSubview(progressView)
            progressView.autoPinEdge(.top, to: .bottom, of: stateLabel, withOffset: 5)
            progressView.autoPinEdge(.bottom, to: .bottom, of: contentView, withOffset: 6)
            progressView.autoPinEdge(.left, to: .right, of: filePreviewView, withOffset: 12)
            progressView.autoPinEdge(.right, to: .left, of: removeButton, withOffset: -80)
        }

        func renderProps() {
            let style = SecureConversations.FileUploadView.Style.Properties(
                style: props.style
            )
            progressView.backgroundColor = style.progressBackgroundColor
            removeButton.tintColor = style.removeButtonColor
            removeButton.setImage(style.removeButtonImage, for: .normal)
            removeButton.accessibilityLabel = style.accessibility.removeButtonAccessibilityLabel
            setFontScalingEnabled(
                style.accessibility.isFontScalingEnabled,
                for: infoLabel
            )
            setFontScalingEnabled(
                style.accessibility.isFontScalingEnabled,
                for: stateLabel
            )

            update(for: props.state)

            self.layer.cornerRadius = style.cornerRadius
            self.backgroundColor = style.backgroundColor
        }

        private func update(for state: FileUpload.State) {
            let style = SecureConversations.FileUploadView.Style.Properties(
                style: props.style
            )
            switch state {
            case .none:
                filePreviewView.props = .init(style: style.filePreview, kind: .none)
                infoLabel.text = nil
                stateLabel.text = nil
                accessibilityValue = nil
                accessibilityIdentifier = nil
            case let .uploading(progress, localFile):
                filePreviewView.props = .init(style: style.filePreview, kind: .file(localFile))
                infoLabel.text = localFile.fileInfoString
                infoLabel.numberOfLines = 1
                infoLabel.font = style.uploading.infoFont
                infoLabel.textColor = style.uploading.infoColor
                stateLabel.text = style.uploading.text
                stateLabel.font = style.uploading.font
                stateLabel.textColor = style.uploading.textColor
                progressView.tintColor = style.progressColor
                progressView.progress = Float(progress)
                let provideProgressText: (Double) -> String = { "\(Int($0 * 100))" }
                accessibilityValue = Self.accessibleProgress(
                    provideProgressText(progress),
                    to: infoLabel.text,
                    accessibility: style.accessibility
                )
                accessibilityIdentifier = "secureConversations_file_attachment_uploading"
            case let .uploaded(localFile):
                filePreviewView.props = .init(style: style.filePreview, kind: .file(localFile))
                infoLabel.text = localFile.fileInfoString
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
                accessibilityIdentifier = "secureConversations_file_attachment_ready_to_send"
            case .error(let error):
                filePreviewView.props = .init(style: style.filePreview, kind: .error)
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
                accessibilityIdentifier = "secureConversations_file_attachment_uploading_error_\(error.accessibilityIdentifierSuffix)"
            }
            accessibilityLabel = stateLabel.text
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
            props.removeTapped()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            // Make FileUploadView `accessibilityFrame` smaller
            // to allow VoiceOver to "see" `removeButton`
            var accFrame = self.frame
            let style = Style.Properties(style: props.style)

            let insetX = style.contentInsets.left + style.contentInsets.right + kRemoveButtonSize.width
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
}

extension SecureConversations.FileUploadView.Props.State {
    init(
        state: GliaWidgets.FileUpload.State,
        localFile: GliaWidgets.LocalFile) {
        switch state {
        case .none:
            self = .none
        case .uploading(let progress):
            self = .uploading(
                progress.value,
                localFile: .init(localFile: localFile)
            )
        case .uploaded:
            self = .uploaded(.init(localFile: localFile))
        case .error(let error):
            self = .error(.init(error: error))
        }
    }
}

extension SecureConversations.FileUploadView.Props.Error {
    init(error: GliaWidgets.FileUpload.Error) {
        switch error {
        case .fileTooBig:
            self = .fileTooBig
        case .unsupportedFileType:
            self = .unsupportedFileType
        case .safetyCheckFailed:
            self = .safetyCheckFailed
        case .network:
            self = .network
        case .generic:
            self = .generic
        }
    }
}

extension SecureConversations.FileUploadView.Props {
    init(
        fileUpload: GliaWidgets.FileUpload,
        style: SecureConversations.FileUploadView.Style,
        removeTapped: Cmd
    ) {
        self.init(
            id: fileUpload.uuid.uuidString,
            style: style,
            state: .init(
                state: fileUpload.state.value,
                localFile: fileUpload.localFile
            ),
            removeTapped: removeTapped
        )
    }
}

extension FileUploadStyle {
    static let initial = Theme().chat.messageEntry.uploadList.item
}

extension SecureConversations.FileUploadView {
    enum Style: Equatable {
        case chat(FileUploadStyle)
        case messageCenter(MessageCenterFileUploadStyle)
    }
}

extension SecureConversations.FileUploadView.Style {
    struct Properties: Equatable {
        /// Style of the file preview.
        var filePreview: FilePreviewStyle
        /// Style of the uploading state.
        var uploading: FileUploadStateStyle
        /// Style of the uploaded state.
        var uploaded: FileUploadStateStyle
        /// Style of the error state.
        var error: FileUploadErrorStateStyle
        /// Foreground color of the upload progress bar.
        var progressColor: UIColor
        /// Foreground color of the upload progress bar in error state.
        var errorProgressColor: UIColor
        /// Background color of the upload progress bar.
        var progressBackgroundColor: UIColor
        /// Image of the remove button.
        var removeButtonImage: UIImage
        /// Color of the remove button image.
        var removeButtonColor: UIColor
        /// Accessibility related properties.
        var accessibility: FileUploadStyle.Accessibility
        var contentInsets: UIEdgeInsets
        var cornerRadius: Double
        var backgroundColor: UIColor
        var removeButtonTopRightOffset: CGSize

        init(style: SecureConversations.FileUploadView.Style) {
            switch style {
            case let .chat(uploadStyle):
                filePreview = uploadStyle.filePreview
                uploading = uploadStyle.uploading
                uploaded = uploadStyle.uploaded
                error = uploadStyle.error
                progressColor = uploadStyle.progressColor
                errorProgressColor = uploadStyle.errorProgressColor
                progressBackgroundColor = uploadStyle.progressBackgroundColor
                removeButtonImage = uploadStyle.removeButtonImage
                removeButtonColor = uploadStyle.removeButtonColor
                accessibility = uploadStyle.accessibility
                contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                cornerRadius = 0
                backgroundColor = .clear
                removeButtonTopRightOffset = .zero
            case let .messageCenter(uploadStyle):
                filePreview = uploadStyle.filePreview
                uploading = uploadStyle.uploading
                uploaded = uploadStyle.uploaded
                error = uploadStyle.error
                progressColor = uploadStyle.progressColor
                errorProgressColor = uploadStyle.errorProgressColor
                progressBackgroundColor = uploadStyle.progressBackgroundColor
                removeButtonImage = uploadStyle.removeButtonImage
                removeButtonColor = uploadStyle.removeButtonColor
                accessibility = uploadStyle.accessibility
                contentInsets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
                cornerRadius = 4
                backgroundColor = uploadStyle.backgroundColor
                removeButtonTopRightOffset = .init(width: -5, height: -14)
            }
        }
    }
}

extension SecureConversations.FileUploadView.Props {
    typealias FilePreviewView = SecureConversations.FilePreviewView

    enum State: Equatable {
        case none
        case uploading(Double, localFile: FilePreviewView.Kind.LocalFile)
        case uploaded(FilePreviewView.Kind.LocalFile)
        case error(Error)
    }

    enum Error: Equatable {
        case fileTooBig
        case unsupportedFileType
        case safetyCheckFailed
        case network
        case generic

        init(with error: CoreSdkClient.SalemoveError) {
            switch error.error {
            case let genericError as CoreSdkClient.GeneralError:
                switch genericError {
                case .networkError:
                    self = .network
                default:
                    self = .generic
                }
            case let fileError as CoreSdkClient.FileError:
                switch fileError {
                case .fileTooBig:
                    self = .fileTooBig
                case .unsupportedFileType:
                    self = .unsupportedFileType
                case .infected:
                    self = .safetyCheckFailed
                default:
                    self = .generic
                }
            default:
                self = .generic
            }
        }

        var accessibilityIdentifierSuffix: String {
            switch self {
            case .fileTooBig: return "file_too_big"
            case .unsupportedFileType: return "unsupported_file_type"
            case .safetyCheckFailed: return "safety_check_failed"
            case .network: return "network"
            case .generic: return "generic"
            }
        }
    }
}

extension SecureConversations.FileUploadView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

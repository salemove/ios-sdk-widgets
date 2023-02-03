import UIKit
#if canImport(QuickLookThumbnailing)
  import QuickLookThumbnailing
#endif

private extension Int {
    static let maxUnscrollableViewsOnDefaultContentSizeCategory = 3
    static let maxUnscrollableViewsOnLargeContentSizeCategory = 2
}

extension SecureConversations {
    class FileUploadListView: UIView {
        struct Props: Equatable {
            let maxUnscrollableViews: Int
            let style: FileUploadListStyle
            let uploads: IdCollection<FileUploadView.Props.Identifier, FileUploadView.Props>
        }

        var props: Props = .init(
            maxUnscrollableViews: 2,
            style: .init(item: .initial),
            uploads: .init()
        ) {
            didSet {
                renderProps()
            }
        }

        private var uploadViews: [FileUploadView] {
            return stackView.arrangedSubviews.compactMap { $0 as? FileUploadView }
        }

        private let scrollView = UIScrollView()
        private let stackView = UIStackView()
        private var heightLayoutConstraint: NSLayoutConstraint!

        var cachedViews = IdCollection<FileUploadView.Props.Identifier, FileUploadView>()

        init() {
            super.init(frame: .zero)
            setup()
            layout()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func addUploadView(_ uploadView: FileUploadView) {
            stackView.insertArrangedSubview(uploadView, at: 0)
            updateHeight()
            addAccessibilityProperties(for: uploadView)
        }

        func removeUploadView(_ uploadView: FileUploadView) {
            stackView.removeArrangedSubview(uploadView)
            uploadView.removeFromSuperview()
            updateHeight()
            removeAccessibilityProperties(for: uploadView)
        }

        func removeAllUploadViews() {
            stackView.removeArrangedSubviews()
            removeAccessibilityPropertiesForAllUploadViews()
            updateHeight()
        }

        private func setup() {
            stackView.axis = .vertical
            // Assign empty array, because `accessibilityElements` is nil initially,
            // and we need to append to/remove from it when views
            // are added to/removed from stack view
            stackView.accessibilityElements = []
        }

        private func layout() {
            heightLayoutConstraint = autoSetDimension(.height, toSize: 0)

            addSubview(scrollView)
            scrollView.autoPinEdgesToSuperviewEdges(with: .zero)

            let contentView = UIView()
            scrollView.addSubview(contentView)
            contentView.autoPinEdgesToSuperviewEdges()
            contentView.autoMatch(.width, to: .width, of: scrollView)

            contentView.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges()
        }

        func updateHeight() {
            let height = uploadViews
                .prefix(props.maxUnscrollableViews)
                .reduce(CGFloat.zero) { result, view in
                    result + view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                }

            heightLayoutConstraint.constant = height
        }

        /// Make `fileUploadView` and `fileUploadView.removeButton` "visible"
        /// for VoiceOver.
        func addAccessibilityProperties(for fileUploadView: FileUploadView) {
            stackView.accessibilityElements?.append(fileUploadView)
            stackView.accessibilityElements?.append(fileUploadView.removeButton)
        }

        /// Remove fileUploadView` and `fileUploadView.removeButton` from
        /// `accessibilityElements`.
        func removeAccessibilityProperties(for fileUploadView: FileUploadView) {
            stackView.accessibilityElements?.removeAll(
                where: {
                    guard let view = $0 as? UIView else { return false }
                    return view === fileUploadView || view === fileUploadView.removeButton
                }
            )
        }

        /// Clear all `accessibilityElements`at once.
        func removeAccessibilityPropertiesForAllUploadViews() {
            stackView.accessibilityElements?.removeAll()
        }

        func renderProps() {
            // Since we need to create/remove views based on the diff
            // in collection of props, we need to have association
            // between each element in collection of props and each
            // corresponding view. This is achieved by having common
            // id for props and view.

            // Check for removal of views.
            var toRemove = [FileUploadView.Props.Identifier]()
            for id in cachedViews.ids where props.uploads[by: id] == nil {
                toRemove.append(id)
            }

            for id in toRemove {
                guard let view = cachedViews[by: id] else { continue }
                removeUploadView(view)
                cachedViews.remove(by: id)
            }

            // Check for addition of views.
            for id in props.uploads.ids where cachedViews[by: id] == nil {
                let uploadView = FileUploadView()
                addUploadView(uploadView)
                cachedViews.append(item: uploadView, identified: id)
            }

            // Assign props for corresponding views
            for uploadProps in props.uploads {
                cachedViews[by: uploadProps.id]?.props = uploadProps
            }
        }
    }
}

extension SecureConversations.FileUploadListView {
    class FileUploadView: UIView {
        typealias FileUpload = Props

        struct Props: Equatable, Identifiying {
            typealias Identifier = String
            let id: Identifier
            let style: FileUploadStyle
            let state: State
            let removeTapped: Cmd
        }

        static let height: CGFloat = 60

        private let contentView = UIView()
        private let infoLabel = UILabel()
        private let stateLabel = UILabel()
        private let filePreviewView = FilePreviewView()
        private let progressView = UIProgressView()
        let removeButton = UIButton()

        private let kContentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        private let kRemoveButtonSize = CGSize(width: 30, height: 30)

        var props: Props {
            didSet {
                renderProps()
            }
        }

        init() {
            self.props = Props(
                id: "",
                style: .initial,
                state: .none,
                removeTapped: .nop
            )
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
            isAccessibilityElement = true
        }

        private func layout() {
            autoSetDimension(.height, toSize: FileUploadView.height, relation: .greaterThanOrEqual)
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
            progressView.backgroundColor = props.style.progressBackgroundColor
            removeButton.tintColor = props.style.removeButtonColor
            removeButton.setImage(props.style.removeButtonImage, for: .normal)
            removeButton.accessibilityLabel = props.style.accessibility.removeButtonAccessibilityLabel
            setFontScalingEnabled(
                props.style.accessibility.isFontScalingEnabled,
                for: infoLabel
            )
            setFontScalingEnabled(
                props.style.accessibility.isFontScalingEnabled,
                for: stateLabel
            )

            update(for: props.state)
        }

        // swiftlint:disable function_body_length
        private func update(for state: FileUpload.State) {
            switch state {
            case .none:
                filePreviewView.props = .init(style: props.style.filePreview, kind: .none)
                infoLabel.text = nil
                stateLabel.text = nil
                accessibilityValue = nil
            case let .uploading(progress, localFile):
                filePreviewView.props = .init(style: props.style.filePreview, kind: .file(localFile))
                infoLabel.text = localFile.fileInfoString
                infoLabel.numberOfLines = 1
                infoLabel.font = props.style.uploading.infoFont
                infoLabel.textColor = props.style.uploading.infoColor
                stateLabel.text = props.style.uploading.text
                stateLabel.font = props.style.uploading.font
                stateLabel.textColor = props.style.uploading.textColor
                progressView.tintColor = props.style.progressColor
                progressView.progress = Float(progress)
                let provideProgressText: (Double) -> String = { "\(Int($0 * 100))" }
                accessibilityValue = Self.accessibleProgress(
                    provideProgressText(progress),
                    to: infoLabel.text,
                    accessibility: props.style.accessibility
                )
            case let .uploaded(localFile):
                filePreviewView.props = .init(style: props.style.filePreview, kind: .file(localFile))
                infoLabel.text = localFile.fileInfoString
                infoLabel.numberOfLines = 1
                infoLabel.font = props.style.uploaded.infoFont
                infoLabel.textColor = props.style.uploaded.infoColor
                stateLabel.text = props.style.uploaded.text
                stateLabel.font = props.style.uploaded.font
                stateLabel.textColor = props.style.uploaded.textColor
                progressView.tintColor = props.style.progressColor
                progressView.progress = 1.0
                accessibilityValue = Self.accessibleProgress(
                    "100",
                    to: infoLabel.text,
                    accessibility: props.style.accessibility
                )
            case .error(let error):
                filePreviewView.props = .init(style: props.style.filePreview, kind: .error) //.error
                infoLabel.text = errorText(from: props.style.error, for: error)
                infoLabel.numberOfLines = 2
                infoLabel.font = props.style.error.infoFont
                infoLabel.textColor = props.style.error.infoColor
                stateLabel.text = props.style.error.text
                stateLabel.font = props.style.error.font
                stateLabel.textColor = props.style.error.textColor
                progressView.tintColor = props.style.errorProgressColor
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
            props.removeTapped()
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
}

extension SecureConversations.FileUploadListView.FileUploadView.Props {
    typealias FilePreviewView = SecureConversations.FileUploadListView.FileUploadView.FilePreviewView

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
    }
}

extension SecureConversations.FileUploadListView.FileUploadView {
    class FilePreviewView: UIView {
        enum Kind: Equatable {
            case none
            case file(LocalFile)
            case fileExtension(String?)
            case error
        }

        struct Props: Equatable {
            let style: FilePreviewStyle
            let kind: Kind
        }

        var props: Props {
            didSet {
                renderProps()
            }
        }

        private let imageView = UIImageView()
        private let label = UILabel()
        private let kSize = CGSize(width: 52, height: 52)

        init() {
            self.props = Props(style: .initial, kind: .none)
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
            clipsToBounds = true
            label.textAlignment = .center
        }

        private func layout() {
            NSLayoutConstraint.autoSetPriority(.defaultHigh) {
                autoSetDimension(.height, toSize: kSize.height)
            }
            autoSetDimension(.width, toSize: kSize.width)

            addSubview(imageView)
            imageView.autoPinEdgesToSuperviewEdges()

            addSubview(label)
            label.autoPinEdge(toSuperviewEdge: .left, withInset: 5)
            label.autoPinEdge(toSuperviewEdge: .right, withInset: 5)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
        }

        func renderProps() {
            layer.cornerRadius = props.style.cornerRadius
            label.font = props.style.fileFont
            label.textColor = props.style.fileColor
            setFontScalingEnabled(
                props.style.accessibility.isFontScalingEnabled,
                for: label
            )

            switch props.kind {
            case .none:
                imageView.image = nil
                label.text = nil
                backgroundColor = props.style.backgroundColor
            case .file(let file):
                imageView.contentMode = .scaleAspectFill
                imageView.image = nil
                label.text = nil
                backgroundColor = props.style.backgroundColor

                // Because thumbnail is generated by the view
                // asynchronously, we need to rely on current state of the view
                // to avoid issuing unnecessary thumnail re-creation.
                switch imageState {
                // If thumbnail is generated, just render it again, to avoid
                // having empty placolder with file extension.
                case let .generated(image, file):
                    self.imageState = .generated(image: image, file: file)
                // If thumbnail has not been generated yet of failed,
                // attempt to create it again.
                case .failed, .notGenerated:
                    self.imageState = .inProgress(file)
                case .inProgress:
                    break
                }

            case .fileExtension(let fileExtension):
                imageView.image = nil
                label.text = fileExtension?.uppercased()
                backgroundColor = props.style.backgroundColor
            case .error:
                imageView.contentMode = .center
                imageView.image = props.style.errorIcon
                imageView.tintColor = props.style.errorIconColor
                label.text = nil
                backgroundColor = props.style.errorBackgroundColor
            }
        }

        private func setPreviewImage(_ image: UIImage?, for file: Kind.LocalFile) {
            guard
                case let .file(currentFile) = self.props.kind,
                file == currentFile
            else { return }

            if let image = image {
                self.imageView.image = image
            } else {
                self.label.text = file.fileExtension.uppercased()
            }
        }

        private func previewImage(for file: Kind.LocalFile, completion: @escaping (UIImage?) -> Void) {
            if #available(iOS 13.0, *) {
                let request = QLThumbnailGenerator.Request(
                    fileAt: file.url,
                    size: kSize,
                    scale: UIScreen.main.scale,
                    representationTypes: .lowQualityThumbnail
                )
                QLThumbnailGenerator.shared.generateRepresentations(for: request) { representation, _, _ in
                    let image = representation?.uiImage
                        ?? UIImage(contentsOfFile: file.url.path)?.resized(to: self.kSize)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            } else {
                let image = UIImage(contentsOfFile: file.url.path)?.resized(to: kSize)
                completion(image)
            }
        }

        enum ThumbnailState: Equatable {
            case notGenerated
            case inProgress(Kind.LocalFile)
            case generated(image: UIImage, file: Kind.LocalFile)
            case failed(Kind.LocalFile)
        }

        var imageState: ThumbnailState = .notGenerated {
            didSet {
                switch imageState {
                case .notGenerated:
                    break
                case let .inProgress(file):
                    previewImage(for: file) { [weak self] image in
                        switch image {
                        case let .some(img):
                            self?.imageState = .generated(image: img, file: file)
                        case .none:
                            self?.imageState = .failed(file)
                        }
                    }
                case let .failed(file):
                    self.setPreviewImage(nil, for: file)
                case let .generated(image, file):
                    self.setPreviewImage(image, for: file)
                }
            }
        }
    }
}

extension SecureConversations.FileUploadListView.FileUploadView.FilePreviewView.ThumbnailState {
    var isLoaded: Bool {
        switch self {
        case .generated:
            return true
        default:
            return false
        }
    }
}

extension SecureConversations.FileUploadListView.FileUploadView.FilePreviewView.Kind {
    struct LocalFile: Equatable {
        var fileExtension: String
        var fileName: String
        let fileSize: Int64?
        let fileSizeString: String?
        let fileInfoString: String?
        let isImage: Bool
        let url: URL
    }
}

private extension FilePreviewStyle {
    static let initial = FileUploadStyle.initial.filePreview
}

private extension FileUploadStyle {
    static let initial = Theme().chat.messageEntry.uploadList.item
}

extension SecureConversations.FileUploadListView.FileUploadView.FilePreviewView.Kind.LocalFile {
    init(localFile: GliaWidgets.LocalFile) {
        self.init(
            fileExtension: localFile.fileExtension,
            fileName: localFile.fileName,
            fileSize: localFile.fileSize,
            fileSizeString: localFile.fileSizeString,
            fileInfoString: localFile.fileInfoString,
            isImage: localFile.isImage,
            url: localFile.url
        )
    }
}

extension SecureConversations.FileUploadListView.FileUploadView.FilePreviewView.Kind {
    init(kind: GliaWidgets.FilePreviewView.Kind) {
        switch kind {
        case .none:
            self = .none
        case let .file(localFile):
            self = .file(.init(localFile: localFile))
        case let .fileExtension(string):
            self = .fileExtension(string)
        case .error:
            self = .error
        }
    }
}

extension SecureConversations.FileUploadListView.FileUploadView.Props.State {
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

extension SecureConversations.FileUploadListView.FileUploadView.Props.Error {
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

extension SecureConversations.FileUploadListView.FileUploadView.Props {
    init(
        fileUpload: GliaWidgets.FileUpload,
        style: GliaWidgets.FileUploadStyle,
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

#warning("TODO: Create dedicated FileUploader for message center.")
typealias MessageCenterFileUploader = FileUploader

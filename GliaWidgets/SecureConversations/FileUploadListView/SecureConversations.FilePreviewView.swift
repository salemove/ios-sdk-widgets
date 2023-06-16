#if canImport(QuickLookThumbnailing)
    import QuickLookThumbnailing
#endif

import UIKit

extension SecureConversations {
    final class FilePreviewView: UIView {
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
        private let environment: Environment

        init(environment: Environment) {
            self.environment = environment
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
            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
            constraints += match(.height, value: kSize.height, priority: .defaultHigh)
            constraints += match(.width, value: kSize.width)

            addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            constraints += imageView.layoutInSuperview()

            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            constraints += label.layoutInSuperview(edges: .horizontal, insets: .init(top: 0, left: 5, bottom: 0, right: 5))
            constraints += label.centerYAnchor.constraint(equalTo: centerYAnchor)
        }

        private func renderProps() {
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
                    scale: environment.uiScreen.scale(),
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

extension SecureConversations.FilePreviewView.ThumbnailState {
    var isLoaded: Bool {
        switch self {
        case .generated:
            return true
        default:
            return false
        }
    }
}

extension SecureConversations.FilePreviewView.Kind {
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

extension SecureConversations.FilePreviewView.Kind.LocalFile {
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

extension SecureConversations.FilePreviewView.Kind {
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

private extension FilePreviewStyle {
    static let initial = FileUploadStyle.initial.filePreview
}

extension SecureConversations.FilePreviewView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

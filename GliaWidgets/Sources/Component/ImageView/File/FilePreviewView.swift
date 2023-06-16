import UIKit
#if canImport(QuickLookThumbnailing)
  import QuickLookThumbnailing
#endif

class FilePreviewView: UIView {
    enum Kind {
        case none
        case file(LocalFile)
        case fileExtension(String?)
        case error
    }

    var kind: Kind = .none {
        didSet { update() }
    }

    private let imageView = UIImageView()
    private let label = UILabel()
    private let style: FilePreviewStyle
    private let kSize = CGSize(width: 52, height: 52)
    private let environment: Environment

    init(with style: FilePreviewStyle, environment: Environment) {
        self.style = style
        self.environment = environment
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        clipsToBounds = true
        layer.cornerRadius = style.cornerRadius

        label.font = style.fileFont
        label.textColor = style.fileColor
        label.textAlignment = .center
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: label
        )

        update()
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

    private func update() {
        switch kind {
        case .none:
            imageView.image = nil
            label.text = nil
            backgroundColor = style.backgroundColor
        case .file(let file):
            imageView.contentMode = .scaleAspectFill
            imageView.image = nil
            label.text = nil
            backgroundColor = style.backgroundColor
            previewImage(for: file) { image in
                self.setPreviewImage(image, for: file)
            }
        case .fileExtension(let fileExtension):
            imageView.image = nil
            label.text = fileExtension?.uppercased()
            backgroundColor = style.backgroundColor
        case .error:
            imageView.contentMode = .center
            imageView.image = style.errorIcon
            imageView.tintColor = style.errorIconColor
            label.text = nil
            backgroundColor = style.errorBackgroundColor
        }
    }

    private func setPreviewImage(_ image: UIImage?, for file: LocalFile) {
        guard
            case let .file(currentFile) = kind,
            file == currentFile
        else { return }

        if let image = image {
            self.imageView.image = image
        } else {
            self.label.text = file.fileExtension.uppercased()
        }
    }

    private func previewImage(for file: LocalFile, completion: @escaping (UIImage?) -> Void) {
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
}

extension FilePreviewView {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
    }
}

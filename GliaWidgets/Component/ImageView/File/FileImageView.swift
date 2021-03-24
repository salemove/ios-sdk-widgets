import UIKit
#if canImport(QuickLookThumbnailing)
  import QuickLookThumbnailing
#endif

class FileImageView: UIView {
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
    private let style: FileImageStyle
    private let kSize = CGSize(width: 52, height: 52)

    init(with style: FileImageStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        clipsToBounds = true
        layer.cornerRadius = 4

        label.font = style.fileFont
        label.textColor = style.fileColor
        label.textAlignment = .center

        update()
    }

    private func layout() {
        autoSetDimensions(to: kSize)

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()

        addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .left, withInset: 5)
        label.autoPinEdge(toSuperviewEdge: .right, withInset: 5)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
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
            label.text = fileExtension
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
}

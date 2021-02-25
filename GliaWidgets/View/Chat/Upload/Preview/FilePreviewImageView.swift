import UIKit
#if canImport(QuickLookThumbnailing)
  import QuickLookThumbnailing
#endif

class FilePreviewImageView: UIView {
    enum State {
        case none
        case file(url: URL)
        case error
    }

    var state: State = .none {
        didSet { update(for: state) }
    }

    private let imageView = UIImageView()
    private let label = UILabel()
    private let style: FilePreviewImageStyle
    private let kSize = CGSize(width: 52, height: 52)

    init(with style: FilePreviewImageStyle) {
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

        update(for: state)
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

    private func update(for state: State) {
        switch state {
        case .none:
            imageView.image = nil
            label.text = nil
            backgroundColor = style.backgroundColor
        case .file(url: let url):
            imageView.contentMode = .scaleAspectFill
            imageView.image = nil
            label.text = nil
            backgroundColor = style.backgroundColor
            previewImage(for: url) { image in
                if let image = image {
                    self.imageView.image = image
                } else {
                    self.label.text = self.fileExtension(for: url)
                }
            }
        case .error:
            imageView.contentMode = .center
            imageView.image = style.errorIcon
            label.text = nil
            backgroundColor = style.errorBackgroundColor
        }
    }

    private func previewImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        if #available(iOS 13.0, *) {
            let request = QLThumbnailGenerator.Request(
                fileAt: url,
                size: kSize,
                scale: UIScreen.main.scale,
                representationTypes: .lowQualityThumbnail
            )
            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, _ in
                if let thumbnail = thumbnail {
                    completion(thumbnail.uiImage)
                } else {
                    completion(nil)
                }
            }
        } else {
            let image = UIImage(contentsOfFile: url.path)?.resized(to: kSize)
            completion(image)
        }
    }

    private func fileExtension(for url: URL) -> String? {
        return url.pathExtension.uppercased()
    }
}

import UIKit

class FileUploadView: UIView {
    enum State {
        case none
        case uploading(progress: ValueProvider<Double>)
        case uploaded
        case error(reason: String)
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

    private func setup() {
        progressView.tintColor = style.progressColor
        progressView.backgroundColor = style.progressBackgroundColor

        cancelButton.tintColor = style.cancelButtonColor
        cancelButton.setImage(style.cancelButtonImage, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    }

    private func layout() {

    }

    private func update(for state: State) {

    }

    @objc private func cancel() {
        cancelTapped?()
    }
}

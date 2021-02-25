import UIKit

class FileUploadView: UIView {
    enum State {
        case uploading(progress: ValueProvider<Double>)
        case uploaded
        case failure(reason: String)
    }

    let height: CGFloat = 60

    private let style: FileUploadStyle

    init(with style: FileUploadStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {

    }

    private func layout() {

    }
}

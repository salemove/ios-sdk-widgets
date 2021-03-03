import UIKit

class FileUploadListView: UIView {
    private var uploadViews = [FileUploadView]()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let style: FileUploadListStyle
    private let kMaxUnscrollableViews = 3

    init(with style: FileUploadListStyle) {
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

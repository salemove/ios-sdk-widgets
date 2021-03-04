import UIKit

class FileUploadListView: UIView {
    private var uploadViews: [FileUploadView] {
        return stackView.arrangedSubviews.compactMap({ $0 as? FileUploadView })
    }
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

    func addUploadView(state: ValueProvider<FileUploadView.State>) {
        let uploadView = FileUploadView(with: style.item)
        stackView.addArrangedSubview(uploadView)
        state.addObserver(self) { state, _ in
            uploadView.state = state
        }
    }

    func removeUploadView(at index: Int) {

    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 0
    }

    private func layout() {
        autoSetDimension(.height,
                         toSize: CGFloat(kMaxUnscrollableViews) * FileUploadView.height,
                         relation: .lessThanOrEqual)

        addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges(with: .zero)

        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        contentView.autoMatch(.width, to: .width, of: scrollView)

        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }
}

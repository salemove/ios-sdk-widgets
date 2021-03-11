import UIKit

class FileUploadListView: UIView {
    var removeTapped: ((Int) -> Void)?

    private var uploadViews: [FileUploadView] {
        return stackView.arrangedSubviews.compactMap({ $0 as? FileUploadView })
    }
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var heightLayoutConstraint: NSLayoutConstraint!
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

    func addUploadView(with state: ValueProvider<FileUploadView.State>) {
        let viewIndex = uploadViews.count
        let uploadView = FileUploadView(with: style.item, state: state)
        uploadView.removeTapped = { [weak self] in self?.removeTapped?(viewIndex) }
        stackView.insertArrangedSubview(uploadView, at: 0)
        updateHeight()
    }

    func removeUploadView(at index: Int) {
        guard stackView.arrangedSubviews.indices ~= index else { return }
        let view = stackView.arrangedSubviews[index]
        stackView.removeArrangedSubview(view)
        view.removeFromSuperview()
        updateHeight()
    }

    func removeAllUploadViews() {
        stackView.removeArrangedSubviews()
        updateHeight()
    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 0
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

    private func updateHeight() {
        let maxHeight = CGFloat(kMaxUnscrollableViews) * FileUploadView.height
        let height = CGFloat(uploadViews.count) * FileUploadView.height
        if height <= maxHeight {
            heightLayoutConstraint.constant = height
        } else {
            heightLayoutConstraint.constant = maxHeight
        }
    }
}

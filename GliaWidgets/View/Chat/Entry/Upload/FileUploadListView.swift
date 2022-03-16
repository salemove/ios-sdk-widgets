import UIKit

class FileUploadListView: UIView {
    var removeTapped: ((FileUpload) -> Void)?

    private var uploadViews: [FileUploadView] {
        return stackView.arrangedSubviews.compactMap { $0 as? FileUploadView }
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

    func addUploadView(with upload: FileUpload) {
        let uploadView = FileUploadView(with: style.item, upload: upload)
        uploadView.removeTapped = { [weak self] in self?.removeTapped?(upload) }
        stackView.insertArrangedSubview(uploadView, at: 0)
        updateHeight()
        addAccessibilityProperties(for: uploadView)
    }

    func removeUploadView(with upload: FileUpload) {
        guard let uploadView = uploadViews.first(where: { $0.upload == upload }) else { return }
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

    private func updateHeight() {
        let maxHeight = CGFloat(kMaxUnscrollableViews) * FileUploadView.height
        let height = CGFloat(uploadViews.count) * FileUploadView.height
        if height <= maxHeight {
            heightLayoutConstraint.constant = height
        } else {
            heightLayoutConstraint.constant = maxHeight
        }
    }

    func addAccessibilityProperties(for fileUploadView: FileUploadView) {
        stackView.accessibilityElements?.append(fileUploadView)
        stackView.accessibilityElements?.append(fileUploadView.removeButton)
    }

    func removeAccessibilityProperties(for fileUploadView: FileUploadView) {
        stackView.accessibilityElements?.removeAll(
            where: {
                guard let view = $0 as? UIView else { return false }
                return view === fileUploadView || view === fileUploadView.removeButton
            }
        )
    }

    func removeAccessibilityPropertiesForAllUploadViews() {
        stackView.accessibilityElements?.removeAll()
    }
}

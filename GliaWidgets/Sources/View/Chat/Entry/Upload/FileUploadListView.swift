// TODO: Remove this file once SecureConversations.FileUploadListView is fully integrated.

/*
import UIKit

private extension Int {
    static let maxUnscrollableViewsOnDefaultContentSizeCategory = 3
    static let maxUnscrollableViewsOnLargeContentSizeCategory = 2
}

final class FileUploadListView: UIView {
    var removeTapped: ((FileUpload) -> Void)?

    // Defines how many attachment items prepared for sending will be displayed without scrolling,
    // depends on preferredContentSizeCategory,
    // if it's a large font size, 2 items will be displayed, otherwise 3 items
    var maxUnscrollableViews: Int {
        if environment.uiApplication.preferredContentSizeCategory() <= .accessibilityMedium {
            return .maxUnscrollableViewsOnDefaultContentSizeCategory
        } else {
            return .maxUnscrollableViewsOnLargeContentSizeCategory
        }
    }

    private var uploadViews: [FileUploadView] {
        return stackView.arrangedSubviews.compactMap { $0 as? FileUploadView }
    }
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var heightLayoutConstraint: NSLayoutConstraint!
    private let style: FileUploadListStyle
    private let environment: Environment

    init(
        with style: FileUploadListStyle,
        environment: Environment
    ) {
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

    func addUploadView(with upload: FileUpload) {
        let uploadView = FileUploadView(with: style.item, upload: upload)
        uploadView.removeTapped = { [weak self] in self?.removeTapped?(upload) }
        stackView.insertArrangedSubview(uploadView, at: 0)
        updateHeight()
        addAccessibilityProperties(for: uploadView)
    }

    func removeUploadView(with upload: FileUpload) {
        guard
            let uploadView = uploadViews.first(where: { $0.upload.uuid == upload.uuid })
        else { return }

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
        // Assign empty array, because `accessibilityElements` is nil initially,
        // and we need to append to/remove from it when views
        // are added to/removed from stack view
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

    func updateHeight() {
        let height = uploadViews
            .prefix(maxUnscrollableViews)
            .reduce(CGFloat.zero) { result, view in
                result + view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            }

        heightLayoutConstraint.constant = height
    }

    /// Make `fileUploadView` and `fileUploadView.removeButton` "visible"
    /// for VoiceOver.
    func addAccessibilityProperties(for fileUploadView: FileUploadView) {
        stackView.accessibilityElements?.append(fileUploadView)
        stackView.accessibilityElements?.append(fileUploadView.removeButton)
    }

    /// Remove fileUploadView` and `fileUploadView.removeButton` from
    /// `accessibilityElements`.
    func removeAccessibilityProperties(for fileUploadView: FileUploadView) {
        stackView.accessibilityElements?.removeAll(
            where: {
                guard let view = $0 as? UIView else { return false }
                return view === fileUploadView || view === fileUploadView.removeButton
            }
        )
    }

    /// Clear all `accessibilityElements`at once.
    func removeAccessibilityPropertiesForAllUploadViews() {
        stackView.accessibilityElements?.removeAll()
    }
}

extension FileUploadListView {
    struct Environment {
        var uiApplication: UIKitBased.UIApplication
    }
}

#if DEBUG
extension FileUploadListView {
    static func mock(environment: Environment) -> FileUploadListView {
        FileUploadListView(
            with: FileUploadListStyle(item: .mock),
            environment: environment
        )
    }
}
#endif
*/

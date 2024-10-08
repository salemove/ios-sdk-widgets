import UIKit

extension SecureConversations {
    final class FileUploadListView: UIView {
        struct Props: Equatable {
            let maxUnscrollableViews: Int
            let style: FileUploadListView.Style
            let uploads: IdCollection<FileUploadView.Props.Identifier, FileUploadView.Props>
            let isScrollingEnabled: Bool
            let preferredContentSizeCategoryChanged: Cmd
        }

        var props: Props = .init(
            maxUnscrollableViews: 2,
            style: .chat(.initial),
            uploads: .init(),
            isScrollingEnabled: false,
            preferredContentSizeCategoryChanged: .nop
        ) {
            didSet {
                renderProps()
            }
        }

        private var uploadViews: [FileUploadView] {
            return stackView.arrangedSubviews.compactMap { $0 as? FileUploadView }
        }

        private let environment: Environment
        private let scrollView = UIScrollView()
        private let stackView = UIStackView()
        private var heightLayoutConstraint: NSLayoutConstraint!

        var cachedViews = IdCollection<FileUploadView.Props.Identifier, FileUploadView>()

        init(environment: Environment) {
            self.environment = environment
            super.init(frame: .zero)
            setup()
            layout()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func addUploadView(_ uploadView: FileUploadView) {
            stackView.insertArrangedSubview(uploadView, at: 0)
            addAccessibilityProperties(for: uploadView)
        }

        func removeUploadView(_ uploadView: FileUploadView) {
            stackView.removeArrangedSubview(uploadView)
            uploadView.removeFromSuperview()
            removeAccessibilityProperties(for: uploadView)
        }

        func removeAllUploadViews() {
            stackView.removeArrangedSubviews()
            removeAccessibilityPropertiesForAllUploadViews()
            updateHeight()
        }

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
                props.preferredContentSizeCategoryChanged()
            }
        }

        private func setup() {
            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.alignment = .fill
            // Assign empty array, because `accessibilityElements` is nil initially,
            // and we need to append to/remove from it when views
            // are added to/removed from stack view
            stackView.accessibilityElements = []
        }

        private func layout() {
            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }

            heightLayoutConstraint = match(.height, value: 0).first
            constraints += heightLayoutConstraint

            addSubview(scrollView)
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            constraints += scrollView.layoutInSuperview()

            let contentView = UIView()
            scrollView.addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            constraints += contentView.layoutInScrollView()

            contentView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            constraints += stackView.layoutInSuperview()
        }

        func updateHeight() {
            let height = uploadViews
                .prefix(props.maxUnscrollableViews)
                .reduce(CGFloat.zero) { result, view in
                    result + view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height +
                    stackView.spacing
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

        func renderProps() {
            // Since we need to create/remove views based on the diff
            // in collection of props, we need to have association
            // between each element in collection of props and each
            // corresponding view. This is achieved by having common
            // id for props and view.

            // Check for removal of views.
            var toRemove = [FileUploadView.Props.Identifier]()
            for id in cachedViews.ids where props.uploads[by: id] == nil {
                toRemove.append(id)
            }

            for id in toRemove {
                guard let view = cachedViews[by: id] else { continue }
                removeUploadView(view)
                cachedViews.remove(by: id)
            }

            // Check for addition of views.
            for id in props.uploads.ids where cachedViews[by: id] == nil {
                guard let uploadViewProps = props.uploads[by: id] else {
                    #if DEBUG
                        assertionFailure("Inconsintentcy in 'props.uploads'")
                    #endif
                    continue
                }
                let uploadView = FileUploadView(
                    props: uploadViewProps,
                    environment: .create(with: environment)
                )
                addUploadView(uploadView)
                cachedViews.append(item: uploadView, identified: id)
            }

            // Assign props for corresponding views
            for uploadProps in props.uploads {
                cachedViews[by: uploadProps.id]?.props = uploadProps
            }

            let style = Style.Properties(style: props.style)
            stackView.spacing = style.spacing
            scrollView.isScrollEnabled = props.isScrollingEnabled

            updateHeight()
        }
    }
}

extension SecureConversations.FileUploadListView {
    enum Style: Equatable {
        case chat(FileUploadListStyle)
        case messageCenter(MessageCenterFileUploadListStyle)
    }
}

extension SecureConversations.FileUploadListView.Style {
    struct Properties: Equatable {
        var item: SecureConversations.FileUploadView.Style
        var spacing: Double

        init(style: SecureConversations.FileUploadListView.Style) {
            switch style {
            case let .chat(uploadListStyle):
                item = .chat(uploadListStyle.item)
                spacing = .zero
            case let .messageCenter(uploadListStyle):
                item = .messageCenter(uploadListStyle.item)
                spacing = 4
            }
        }
    }
}

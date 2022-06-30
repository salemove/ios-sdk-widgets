import UIKit

class ChatMessageView: UIView {
    let style: ChatMessageStyle
    let contentViews = UIStackView()
    var fileTapped: ((LocalFile) -> Void)?
    var downloadTapped: ((FileDownload) -> Void)?
    var linkTapped: ((URL) -> Void)?

    private let contentAlignment: ChatMessageContentAlignment
    private let environment: Environment

    init(
        with style: ChatMessageStyle,
        contentAlignment: ChatMessageContentAlignment,
        environment: Environment
    ) {
        self.style = style
        self.contentAlignment = contentAlignment
        self.environment = environment
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func appendContent(_ content: ChatMessageContent, animated: Bool) {
        switch content {
        case let .text(text, accProperties):
            let contentView = ChatTextContentView(
                with: style.text,
                contentAlignment: contentAlignment,
                environment: .init(
                    uiApplication: environment.uiApplication
                )
            )
            contentView.text = text
            contentView.linkTapped = { [weak self] in self?.linkTapped?($0) }
            contentView.accessibilityProperties = .init(
                label: accProperties.label,
                value: accProperties.value
            )
            appendContentView(contentView, animated: animated)
        case let .files(files, accProperties):
            let contentViews = self.contentViews(
                for: files,
                accessibilityProperties: accProperties
            )
            appendContentViews(contentViews, animated: animated)
        case let .downloads(downloads, accProperties):
            let contentViews = self.contentViews(
                for: downloads,
                accessibilityProperties: accProperties
            )
            appendContentViews(contentViews, animated: animated)
        default:
            break
        }
    }

    func appendContentViews(_ contentViews: [UIView], animated: Bool) {
        contentViews.forEach { appendContentView($0, animated: animated) }
    }

    func appendContentView(_ contentView: UIView, animated: Bool) {
        contentViews.addArrangedSubview(contentView)
        contentView.isHidden = animated

        // Make sure that order of accessible elements is preserved the same way
        // as it is displayed. Otherwise, for example message sent along with attachment is read
        // by VoiceOver after attachment, even though it is situated above attachment.
        contentViews.accessibilityElements?.append(contentView)

        if animated {
            contentViews.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) {
                contentView.isHidden = false
                self.contentViews.layoutIfNeeded()
            }
        }
    }

    func setup() {
        contentViews.axis = .vertical
        contentViews.spacing = 4
        // Add empty list of accessible elements to be populated later,
        // as visual elements are added to `contentViews`.
        contentViews.accessibilityElements = []
    }

    private func contentViews(
        for files: [LocalFile],
        accessibilityProperties: ChatFileContentView.AccessibilityProperties
    ) -> [ChatFileContentView] {
        return files.compactMap { file in
            if file.isImage {
                return ChatImageFileContentView(
                    with: style.imageFile,
                    content: .localFile(file),
                    contentAlignment: contentAlignment,
                    accessibilityProperties: accessibilityProperties,
                    tap: { [weak self] in self?.fileTapped?(file) }
                )
            } else {
                return ChatFileDownloadContentView(
                    with: style.fileDownload,
                    content: .localFile(file),
                    accessibilityProperties: accessibilityProperties,
                    tap: { [weak self] in self?.fileTapped?(file) }
                )
            }
        }
    }

    private func contentViews(
        for downloads: [FileDownload],
        accessibilityProperties: ChatFileContentView.AccessibilityProperties
    ) -> [ChatFileContentView] {
        return downloads.compactMap { download in
            if download.file.isImage {
                return ChatImageFileContentView(
                    with: style.imageFile,
                    content: .download(download),
                    contentAlignment: contentAlignment,
                    accessibilityProperties: accessibilityProperties,
                    tap: { [weak self] in self?.downloadTapped?(download) }
                )
            } else {
                return ChatFileDownloadContentView(
                    with: style.fileDownload,
                    content: .download(download),
                    accessibilityProperties: accessibilityProperties,
                    tap: { [weak self] in self?.downloadTapped?(download) }
                )
            }
        }
    }
}

extension ChatMessageView {
    struct Environment {
        var uiApplication: UIKitBased.UIApplication
    }
}

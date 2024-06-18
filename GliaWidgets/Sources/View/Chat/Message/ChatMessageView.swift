import UIKit

class ChatMessageView: BaseView {
    let style: Theme.ChatMessageStyle
    let contentViews = UIStackView().makeView()
    var fileTapped: ((LocalFile) -> Void)?
    var downloadTapped: ((FileDownload) -> Void)?
    var linkTapped: ((URL) -> Void)?

    private let contentAlignment: ChatMessageContentAlignment
    private let environment: Environment

    init(
        with style: Theme.ChatMessageStyle,
        contentAlignment: ChatMessageContentAlignment,
        environment: Environment
    ) {
        self.style = style
        self.contentAlignment = contentAlignment
        self.environment = environment
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    func appendContent(_ content: ChatMessageContent, animated: Bool) {
        let style = Theme.ChatTextContentStyle(
            text: style.text,
            background: style.background,
            accessibility: .init(
                value: style.accessibility.value,
                isFontScalingEnabled: style.accessibility.isFontScalingEnabled
            )
        )
        switch content {
        case let .text(text, accProperties):
            let contentView = ChatTextContentView(
                with: style,
                contentAlignment: contentAlignment
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
        case let .attributedText(text, _):
            let contentView = ChatTextContentView(
                with: style,
                contentAlignment: contentAlignment
            )
            contentView.attributedText = text
            contentView.linkTapped = { [weak self] in self?.linkTapped?($0) }
            appendContentView(contentView, animated: animated)
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
        if animated {
            contentViews.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) {
                contentView.isHidden = false
                self.contentViews.layoutIfNeeded()
            }
        }
    }

    override func setup() {
        super.setup()
        contentViews.axis = .vertical
        contentViews.spacing = 4
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
                    environment: .init(uiScreen: environment.uiScreen),
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
                    environment: .init(uiScreen: environment.uiScreen),
                    tap: { [weak self] in self?.downloadTapped?(download) }
                )
            }
        }
    }
}

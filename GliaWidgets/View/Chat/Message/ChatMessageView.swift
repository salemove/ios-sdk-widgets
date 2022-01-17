import UIKit

class ChatMessageView: UIView {
    let style: ChatMessageStyle
    let contentViews = UIStackView()
    var fileTapped: ((LocalFile) -> Void)?
    var downloadTapped: ((FileDownload) -> Void)?
    var linkTapped: ((URL) -> Void)?

    private let contentAlignment: ChatMessageContentAlignment

    init(with style: ChatMessageStyle, contentAlignment: ChatMessageContentAlignment) {
        self.style = style
        self.contentAlignment = contentAlignment
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func appendContent(_ content: ChatMessageContent, animated: Bool) {
        switch content {
        case .text(let text):
            let contentView = ChatTextContentView(with: style.text, contentAlignment: contentAlignment)
            contentView.text = text
            contentView.linkTapped = { [weak self] in self?.linkTapped?($0) }
            appendContentView(contentView, animated: animated)
        case .files(let files):
            let contentViews = self.contentViews(for: files)
            appendContentViews(contentViews, animated: animated)
        case .downloads(let downloads):
            let contentViews = self.contentViews(for: downloads)
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

        if animated {
            contentViews.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) { [weak self] in
                contentView.isHidden = false
                self?.contentViews.layoutIfNeeded()
            }
        }
    }

    func setup() {
        contentViews.axis = .vertical
        contentViews.spacing = 4
    }

    private func contentViews(for files: [LocalFile]) -> [ChatFileContentView] {
        return files.compactMap { file in
            if file.isImage {
                return ChatImageFileContentView(
                    with: style.imageFile,
                    content: .localFile(file),
                    contentAlignment: contentAlignment,
                    tap: { [weak self] in self?.fileTapped?(file) }
                )
            } else {
                return ChatFileDownloadContentView(
                    with: style.fileDownload,
                    content: .localFile(file),
                    tap: { [weak self] in self?.fileTapped?(file) }
                )
            }
        }
    }

    private func contentViews(for downloads: [FileDownload]) -> [ChatFileContentView] {
        return downloads.compactMap { download in
            if download.file.isImage {
                return ChatImageFileContentView(
                    with: style.imageFile,
                    content: .download(download),
                    contentAlignment: contentAlignment,
                    tap: { [weak self] in self?.downloadTapped?(download) }
                )
            } else {
                return ChatFileDownloadContentView(
                    with: style.fileDownload,
                    content: .download(download),
                    tap: { [weak self] in self?.downloadTapped?(download) }
                )
            }
        }
    }
}

import UIKit

class ChatMessageView: UIView {
    let style: ChatMessageStyle
    let contentViews = UIStackView()

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
            appendContentView(contentView, animated: animated)
        case .files(let files):
            let contentViews = self.contentViews(for: files)
            appendContentViews(contentViews, animated: animated)
        case .downloads(let downloads):
            let contentViews = self.contentViews(for: downloads)
            appendContentViews(contentViews, animated: animated)
        }
    }

    func appendContentViews(_ contentViews: [UIView], animated: Bool) {
        contentViews.forEach({ appendContentView($0, animated: animated) })
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

    func setup() {
        contentViews.axis = .vertical
        contentViews.spacing = 4
    }

    private func contentViews(for files: [LocalFile]) -> [ChatFileContentView] {
        return files.compactMap({
            if $0.isImage {
                let contentView = ChatImageFileContentView(with: style.imageFile, content: .localFile($0))
                return contentView
            } else {
                return nil
            }
        })
    }

    private func contentViews(for downloads: [FileDownload<ChatEngagementFile>]) -> [ChatFileContentView] {
        return downloads.compactMap({
            if $0.file.isImage {
                let contentView = ChatImageFileContentView(with: style.imageFile, content: .download($0))
                return contentView
            } else {
                let contentView = ChatFileDownloadContentView(with: style.fileDownload, content: .download($0))
                return contentView
            }
        })
    }
}

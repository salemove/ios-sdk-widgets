import UIKit

class ChatMessageView: UIView {
    let style: ChatMessageStyle
    let contentViews = UIStackView()

    init(with style: ChatMessageStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func appendContent(_ content: ChatMessageContent, animated: Bool) {
        switch content {
        case .text(let text):
            let contentView = ChatTextContentView(with: style.text)
            contentView.text = text
            appendContentView(contentView, animated: animated)
        case .files(let files):
            break
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

    private func contentViews(for downloads: [FileDownload<ChatEngagementFile>]) -> [ChatFileContentView] {
        return downloads.compactMap({
            let state = ValueProvider<ChatFileContentView.State>(with: .init(with: $0.state.value))
            if $0.file.isImage {
                let contentView = ChatImageFileContentView(with: style.imageFile, state: state)
                return contentView
            } else {
                return nil
            }
        })
    }
}

private extension ChatFileContentView.State {
    init(with state: FileDownload<ChatEngagementFile>.State) {
        switch state {
        case .none:
            self = .none
        case .downloading(file: let file, progress: let progress):
            self = .downloading(name: file.name, size: file.size, progress: progress)
        case .downloaded(file: let file, url: let url):
            self = .downloaded(name: file.name, size: file.size, url: url)
        case .error(let error):
            self = .error(.init(with: error))
        }
    }
}

private extension ChatFileContentView.Error {
    init(with error: FileDownload<ChatEngagementFile>.Error) {
        switch error {
        case .network:
            self = .network
        case .generic:
            self = .generic
        case .missingFileID:
            self = .generic
        case .deleted:
            self = .generic
        }
    }
}

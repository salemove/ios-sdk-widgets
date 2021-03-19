import UIKit

class ChatFileContentView: UIView {
    enum Content {
        case localFile(LocalFile)
        case download(FileDownload<ChatEngagementFile>)
    }

    private let style: ChatFileContentStyle
    private let content: Content

    init(with style: ChatFileContentStyle, content: Content) {
        self.style = style
        self.content = content
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with file: LocalFile) {}
    func update(with download: FileDownload<ChatEngagementFile>) {}

    func setup() {
        backgroundColor = style.backgroundColor

        switch content {
        case .localFile(let file):
            update(with: file)
        case .download(let download):
            update(with: download)
            download.state.addObserver(self) { _, _ in
                self.update(with: download)
            }
        }
    }

    func layout() {}
}

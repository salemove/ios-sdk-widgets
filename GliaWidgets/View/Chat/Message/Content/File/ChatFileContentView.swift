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

    func update(for file: LocalFile) {}
    func update(for downloadState: FileDownload<ChatEngagementFile>.State) {}

    func setup() {
        backgroundColor = style.backgroundColor

        switch content {
        case .localFile(let file):
            update(for: file)
        case .download(let download):
            update(for: download.state.value)
            download.state.addObserver(self) { state, _ in
                self.update(for: state)
            }
        }
    }

    func layout() {}
}

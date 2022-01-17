import UIKit

class ChatFileContentView: UIView {
    enum Content {
        case localFile(LocalFile)
        case download(FileDownload)
    }

    private let style: ChatFileContentStyle
    private let content: Content
    private let tap: () -> Void
    private var disposables: [Disposable] = []

    init(with style: ChatFileContentStyle, content: Content, tap: @escaping () -> Void) {
        self.style = style
        self.content = content
        self.tap = tap

        super.init(frame: .zero)

        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with file: LocalFile) {}
    func update(with download: FileDownload) {}

    func setup() {
        switch content {
        case .localFile(let file):
            update(with: file)

        case .download(let download):
            update(with: download)

            download.state
                .observe({ [weak self] _ in
                    self?.update(with: download)
                })
                .add(to: &disposables)
        }

        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(tapped))
        addGestureRecognizer(tapRecognizer)
    }

    func layout() {}

    @objc private func tapped() {
        tap()
    }
}

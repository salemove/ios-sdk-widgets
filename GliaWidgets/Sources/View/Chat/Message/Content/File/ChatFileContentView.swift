import UIKit

class ChatFileContentView: UIView {
    enum Content {
        case localFile(LocalFile)
        case download(FileDownload)
    }

    private let style: ChatFileContentStyle
    private let content: Content
    private let tap: () -> Void
    let accessibilityProperties: ChatFileContentView.AccessibilityProperties

    init(
        with style: ChatFileContentStyle,
        content: Content,
        accessibilityProperties: ChatFileContentView.AccessibilityProperties,
        tap: @escaping () -> Void
    ) {
        self.style = style
        self.content = content
        self.tap = tap
        self.accessibilityProperties = accessibilityProperties
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
            download.state.addObserver(self) { [weak self] _, _ in
                self?.update(with: download)
            }
        }

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapped)
        )
        addGestureRecognizer(tapRecognizer)

        isAccessibilityElement = true
        accessibilityElements = []

        let accProperties = sharedAccessibility()
        accessibilityLabel = accProperties.label
        accessibilityValue = accProperties.value
    }

    func layout() {}

    @objc private func tapped() {
        tap()
    }
}

extension ChatFileContentView {
    struct AccessibilityProperties {
        var from: From
    }

    func sharedAccessibility() -> (label: String, value: String?) {
        let fileValue: String?

        switch content {
        case .localFile(let file):
            fileValue = file.accessibilityProperties.value
        case .download(let download):
            fileValue = download.accessibilityProperties.value

        }

        let sender: String

        switch accessibilityProperties.from {
        case let .operator(operatorName):
            sender = operatorName
        case .visitor:
            sender = style.accessibility.youAccessibilityPlaceholder
        }

       return (style.accessibility.contentAccessibilityLabel.withFileSender(sender), fileValue)
    }
}

extension ChatFileContentView.AccessibilityProperties {
    enum From {
        case `operator`(String)
        case visitor
    }
}

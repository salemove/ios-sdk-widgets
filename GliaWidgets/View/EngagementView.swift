import UIKit

class EngagementView: View {
    let header: Header
    let queueView: QueueView

    private let style: EngagementStyle

    init(with style: EngagementStyle) {
        self.style = style
        self.header = Header(with: style.header)
        self.queueView = QueueView(with: style.queue)
        super.init()
        setup()
        layout()
    }

    private func setup() {
        backgroundColor = style.backgroundColor
    }

    private func layout() {}
}

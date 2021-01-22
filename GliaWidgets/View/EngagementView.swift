import UIKit

class EngagementView: View {
    let header: Header
    let connectView: ConnectView

    private let style: EngagementStyle

    init(with style: EngagementStyle) {
        self.style = style
        self.header = Header(with: style.header)
        self.connectView = ConnectView(with: style.connect)
        super.init()
        setup()
        layout()
    }

    private func setup() {
        backgroundColor = style.backgroundColor
    }

    private func layout() {}
}

import UIKit

class CallView: EngagementView {
    private let style: CallStyle
    private let contentView = UIView()

    init(with style: CallStyle) {
        self.style = style
        super.init(with: style)
        setup()
        layout()
    }

    private func setup() {}

    private func layout() {
        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(with: .zero,
                                            excludingEdge: .bottom)

        addSubview(contentView)
        contentView.autoPinEdge(.top, to: .bottom, of: header)
        contentView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
    }
}

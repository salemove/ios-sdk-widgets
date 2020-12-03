import UIKit

class AlertView: UIView {
    private let style: AlertStyle
    private let kContentInsets = UIEdgeInsets(top: 28, left: 32, bottom: 28, right: 32)

    public init(with style: AlertStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = style.backgroundColor
    }

    private func layout() {

    }
}

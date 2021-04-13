import UIKit
import PureLayout

class HeaderButton: UIButton {
    var tap: (() -> Void)?

    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            alpha = isEnabled ? 1.0 : 0.6
        }
    }

    private let style: HeaderButtonStyle
    private let kSize = CGSize(width: 30, height: 30)

    init(with style: HeaderButtonStyle, tap: (() -> Void)? = nil) {
        self.style = style
        self.tap = tap
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        tintColor = style.color
        setImage(style.image, for: .normal)
        setImage(style.image, for: .highlighted)
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    private func layout() {
        autoSetDimensions(to: kSize)
    }

    @objc private func tapped() {
        tap?()
    }
}

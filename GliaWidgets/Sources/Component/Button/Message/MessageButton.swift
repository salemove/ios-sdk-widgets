import UIKit

class MessageButton: UIButton {
    var tap: (() -> Void)?

    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            style = isEnabled ? .enabled(styleStates.enabled)
                              : .disabled(styleStates.disabled)
        }
    }

    private let styleStates: MessageButtonStyle
    private var style: StateStyle {
        didSet {
            renderStyle()
        }
    }
    private let width: CGFloat = 30

    init(
        with styleStates: MessageButtonStyle,
        tap: (() -> Void)? = nil
    ) {
        self.styleStates = styleStates
        self.style = .enabled(styleStates.enabled)
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
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        renderStyle()
    }

    private func layout() {
        match(.width, value: width).activate()
    }

    @objc private func tapped() {
        tap?()
    }

    private func renderStyle() {
        tintColor = style.color
        setImage(style.image, for: .normal)
        setImage(style.image, for: .highlighted)
        accessibilityLabel = style.accessibility.accessibilityLabel
        isAccessibilityElement = isEnabled
    }
}

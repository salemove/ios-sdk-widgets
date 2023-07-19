import UIKit

class Button: AdjustedTouchAreaButton {
    var tap: (() -> Void)?

    var touchAreaInsets: TouchAreaInsets?

    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            alpha = isEnabled ? 1.0 : 0.6
        }
    }

    private let kind: ButtonKind
    private var activityIndicator: UIActivityIndicatorView?

    init(kind: ButtonKind, tap: (() -> Void)? = nil) {
        self.kind = kind
        self.tap = tap
        super.init(touchAreaInsets: kind.properties.touchAreaInsets)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let properties = kind.properties

        backgroundColor = properties.backgroundColor
        titleLabel?.font = properties.font
        setTitle(properties.title, for: .normal)
        setTitleColor(properties.fontColor, for: .normal)

        properties.contentEdgeInsets.map { self.contentEdgeInsets = $0 }
        properties.imageEdgeInsets.map { self.imageEdgeInsets = $0 }
        properties.contentHorizontalAlignment.map { self.contentHorizontalAlignment = $0 }
        properties.contentVerticalAlignment.map { self.contentVerticalAlignment = $0 }
        properties.cornerRadius.map { layer.cornerRadius = $0 }
        properties.borderWidth.map { layer.borderWidth = $0 }
        properties.borderColor.map { layer.borderColor = $0.cgColor }
        properties.shadowColor.map { layer.shadowColor = $0.cgColor }
        properties.shadowOffset.map { layer.shadowOffset = $0 }
        properties.shadowOpacity.map { layer.shadowOpacity = $0 }
        properties.shadowRadius.map { layer.shadowRadius = $0 }
        properties.width.map { match(.width, value: $0).activate() }
        properties.height.map { match(.height, value: $0).activate() }
        setImage(properties.image, for: .normal)
        setImage(properties.image, for: .highlighted)

        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    private func layout() {}

    @objc private func tapped() {
        tap?()
    }
}

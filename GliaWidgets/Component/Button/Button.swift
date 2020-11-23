import UIKit
import PureLayout

class Button: UIButton {
    var tap: (() -> Void)?

    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            alpha = isEnabled ? 1.0 : 0.6
        }
    }

    private let kind: ButtonKind
    private var activityIndicator: UIActivityIndicatorView?

    init(kind: ButtonKind) {
        self.kind = kind
        super.init(frame: .zero)
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

        if let contentEdgeInsets = properties.contentEdgeInsets {
            self.contentEdgeInsets = contentEdgeInsets
        }

        if let imageEdgeInsets = properties.imageEdgeInsets {
            self.imageEdgeInsets = imageEdgeInsets
        }

        if let width = properties.width {
            autoSetDimension(.width, toSize: width)
        }

        if let height = properties.height {
            autoSetDimension(.height, toSize: height)
        }

        if let cornerRadius = properties.cornerRadius {
            layer.cornerRadius = cornerRadius
        }

        if let borderWidth = properties.borderWidth {
            layer.borderWidth = borderWidth
        }

        if let borderColor = properties.borderColor {
            layer.borderColor = borderColor.cgColor
        }

        if let shadowColor = properties.shadowColor {
            layer.shadowColor = shadowColor.cgColor
        }

        if let shadowOffset = properties.shadowOffset {
            layer.shadowOffset = shadowOffset
        }

        if let shadowOpacity = properties.shadowOpacity {
            layer.shadowOpacity = shadowOpacity
        }

        if let shadowRadius = properties.shadowRadius {
            layer.shadowRadius = shadowRadius
        }

        setImage(properties.image, for: .normal)

        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    private func layout() {}

    @objc private func tapped() {
        tap?()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let insets = kind.properties.touchAreaInsets else {
            return super.point(inside: point, with: event)
        }

        let area = bounds.insetBy(dx: insets.dx, dy: insets.dy)

        return area.contains(point)
    }
}

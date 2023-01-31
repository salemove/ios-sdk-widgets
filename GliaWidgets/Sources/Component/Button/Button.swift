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

    init(kind: ButtonKind, tap: (() -> Void)? = nil) {
        self.kind = kind
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
        properties.width.map {
            let height = $0
            autoSetDimension(.width, toSize: height)
        }
        properties.height.map {
            let height = $0
            autoSetDimension(.height, toSize: height)
        }

        setImage(properties.image, for: .normal)
        setImage(properties.image, for: .highlighted)

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

import UIKit

class FlipCameraButton: UIButton {
    static let size = CGSize(width: 40, height: 40)
    static let bottomTrailingPadding: CGFloat = -8

    struct Props: Equatable {
        struct Accessibility: Equatable {
            let accessibilityLabel: String
            let accessibilityHint: String
        }

        let style: FlipCameraButtonStyle
        let tap: Cmd?
        let accessibility: Accessibility

    }

    var props = Props(
        style: .nop,
        tap: nil,
        accessibility: .nop
    ) {
        didSet {
            renderProps()
        }
    }

    private var renderedStyle: FlipCameraButtonStyle = .nop {
        didSet {
            guard renderedStyle != oldValue else {
                return
            }
            renderStyle(renderedStyle, for: .normal)
        }
    }

    init() {
        super.init(frame: .zero)
        self.setup()
        // Force rendering of initial style properties.
        renderProps()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
    }

    private func renderStyle(_ style: FlipCameraButtonStyle, for controlState: UIControl.State) {
        self.setBackgroundColor(color: style.backgroundColor.color, forState: controlState)
        self.setImage(Asset.flipCamera.image.image(withTintColor: style.imageColor.color), for: controlState)
    }

    private func renderProps() {
        self.isHidden = props.tap == nil
        self.renderedStyle = props.style
        self.accessibilityLabel = props.accessibility.accessibilityLabel
        self.accessibilityHint = props.accessibility.accessibilityHint
    }

    @objc
    private func handleTap() {
        props.tap?()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = min(self.bounds.width, self.self.bounds.width) * 0.5
    }
}

extension FlipCameraButton.Props.Accessibility {
    static let nop = Self(accessibilityLabel: "", accessibilityHint: "")
}

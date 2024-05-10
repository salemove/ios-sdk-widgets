import UIKit

class FlipCameraButton: UIButton {
    static let size = CGSize(width: 40, height: 40)
    static let bottomTrailingPadding: CGFloat = -8

    struct Props: Equatable {
        let style: FlipCameraButtonStyle
        let tap: Cmd?
        let accessibilityLabel: String
    }

    var props = Props(
        style: .nop,
        tap: nil,
        accessibilityLabel: ""
    ) {
        didSet {
            renderProps()
        }
    }

    private var renderedActiveState: FlipCameraButtonStyle.State = .nop {
        didSet {
            guard renderedActiveState != oldValue else {
                return
            }
            renderStyleState(renderedActiveState, for: .normal)
        }
    }

    private var renderedInactiveState: FlipCameraButtonStyle.State = .nop {
        didSet {
            guard renderedInactiveState != oldValue else {
                return
            }
            renderStyleState(renderedInactiveState, for: .disabled)
        }
    }

    private var renderedSelectedState: FlipCameraButtonStyle.State = .nop {
        didSet {
            guard renderedSelectedState != oldValue else {
                return
            }
            renderStyleState(renderedSelectedState, for: .highlighted)
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

    private func renderStyleState(_ styleState: FlipCameraButtonStyle.State, for controlState: UIControl.State) {
        self.setBackgroundColor(color: styleState.backgroundColor.color, forState: controlState)
        self.setImage(Asset.flipCamera.image.image(withTintColor: styleState.imageColor.color), for: controlState)
    }

    private func renderProps() {
        self.isHidden = props.tap == nil
        self.renderedActiveState = props.style.activeState
        self.renderedInactiveState = props.style.inactiveState
        self.renderedSelectedState = props.style.selectedState
        self.accessibilityLabel = props.accessibilityLabel
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

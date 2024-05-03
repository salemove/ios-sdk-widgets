import UIKit

struct FlipCameraButtonStyle: Equatable {
    struct State: Equatable {
        let background: ColorType
        let imageColor: ColorType
    }

    let activeState: State
    let inactiveState: State
    let selectedState: State
}

class FlipCameraButton: UIButton {
    static let size = CGSize(width: 40, height: 40)
    static let bottomTrailingPadding: CGFloat = -8

    struct Props: Equatable {
        let style: FlipCameraButtonStyle
        let tap: Cmd?
    }

    var props = Props(
        style: .init(activeState: .nop, inactiveState: .nop, selectedState: .nop),
        tap: nil
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

    func renderStyleState(_ styleState: FlipCameraButtonStyle.State, for controlState: UIControl.State) {
        self.setBackgroundColor(color: styleState.background.color, forState: controlState)
        self.setImage(Asset.flipCamera.image.image(withTintColor: styleState.imageColor.color), for: controlState)
    }

    private func renderProps() {
        self.isHidden = props.tap == nil
        self.renderedActiveState = props.style.activeState
        self.renderedInactiveState = props.style.inactiveState
        self.renderedSelectedState = props.style.selectedState
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

extension FlipCameraButtonStyle.State {
    static let nop = Self(background: .fill(color: .clear), imageColor: .fill(color: .clear))
}

extension FlipCameraButtonStyle {
    static let custom = Self(
        activeState: .init(background: .fill(color: .init(hex: "#04728c")), imageColor: .fill(color: .init(hex: "#FFFFFF"))),
        inactiveState: .init(background: .fill(color: .init(hex: "#042835")), imageColor: .fill(color: .init(hex: "#FFFFFF"))),
        selectedState: .init(background: .fill(color: .init(hex: "#000000")), imageColor: .fill(color: .init(hex: "#FFFFFF")))
    )
}

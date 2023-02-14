import UIKit

/// Defines button in Header
///
final class HeaderButton: UIButton {
    var props: Props {
        didSet {
            renderProps()
        }
    }

    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            alpha = isEnabled ? 1.0 : 0.6
        }
    }

    private var isDefineLayoutNeeded = true

    init(with props: Props) {
        self.props = props
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        defer { super.updateConstraints() }
        if isDefineLayoutNeeded {
            isDefineLayoutNeeded = false
            defineLayout()
        }
    }

    func renderProps() {
        tintColor = props.style.color
        setImage(props.style.image, for: .normal)
        setImage(props.style.image, for: .highlighted)
        accessibilityLabel = props.style.accessibility.label
        accessibilityHint = props.style.accessibility.hint
    }

    private func setup() {
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    private func defineLayout() {
        renderProps()
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: props.size.width),
            heightAnchor.constraint(equalToConstant: props.size.height)
        ])
    }

    @objc private func tapped() {
        props.tap()
    }
}

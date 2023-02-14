import UIKit

class ActionButton: UIButton {
    var props: Props {
        didSet {
            renderProps()
        }
    }

    private let contentInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

    init(props: Props) {
        self.props = props
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func renderProps() {
        setTitle(props.title, for: .normal)
        contentEdgeInsets = contentInsets
        clipsToBounds = true
        layer.masksToBounds = false
        layer.cornerRadius = props.style.cornerRaidus ?? 0

        layer.borderColor = props.style.borderColor?.cgColor
        layer.borderWidth = props.style.borderWidth ?? 0.0

        layer.shadowColor = props.style.shadowColor?.cgColor
        layer.shadowOffset = props.style.shadowOffset ?? .zero
        layer.shadowOpacity = props.style.shadowOpacity ?? (props.style.backgroundColor == .fill(color: .clear) ? 0.0 : 0.2)
        layer.shadowRadius = props.style.shadowRadius ?? 0.0

        titleLabel?.font = props.style.titleFont
        setTitleColor(props.style.titleColor, for: .normal)
        titleLabel?.textAlignment = .center
        accessibilityLabel = props.style.title
        titleLabel?.adjustsFontSizeToFitWidth = true
        setFontScalingEnabled(
            props.style.accessibility.isFontScalingEnabled,
            for: self
        )
        switch props.style.backgroundColor {
        case .fill(let color):
            backgroundColor = color
        case .gradient(let colors):
            makeGradientBackground(
                colors: colors,
                cornerRadius: props.style.cornerRaidus
            )
        }
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(
                width: props.style.cornerRaidus ?? 0,
                height: props.style.cornerRaidus ?? 0
            )
        ).cgPath
    }

    private func setup() {
        renderProps()
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: props.height)
        ])
    }

    @objc private func tapped() {
        props.tap()
    }
}

extension ActionButton {
    struct Props: Equatable {
        var style: ActionButtonStyle
        var height: CGFloat
        var tap: Cmd
        var title: String
        var accessibilityIdentifier: String

        init(
            style: ActionButtonStyle = .init(title: "", titleFont: .systemFont(ofSize: 16), titleColor: .white, backgroundColor: .fill(color: .blue)),
            height: CGFloat = 40,
            tap: Cmd = .nop,
            title: String = "",
            accessibilityIdentifier: String = ""
        ) {
            self.style = style
            self.height = height
            self.tap = tap
            self.title = title
            self.accessibilityIdentifier = accessibilityIdentifier.isEmpty ? title : accessibilityIdentifier
        }
    }
}

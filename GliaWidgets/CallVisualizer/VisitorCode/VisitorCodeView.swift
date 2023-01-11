import UIKit

extension CallVisualizer {
    final class VisitorCodeView: BaseView {
        struct Props: Equatable {
            enum ViewType: Equatable {
                case alert(closeButtonTap: Cmd)
                case embedded
            }

            let viewType: ViewType
            let style: VisitorCodeStyle
            let visitorCode: String
            let isPoweredByShown: Bool
            var isShadowNeeded: Bool {
                switch viewType {
                case .alert:
                    return true
                case .embedded:
                    return false
                }
            }

            var closeButtonTap: Cmd? {
                switch viewType {
                case let .alert(closeButtonTap):
                    return closeButtonTap
                case .embedded:
                    return nil
                }
            }

            init(
                viewType: ViewType = .alert(closeButtonTap: .nop),
                style: VisitorCodeStyle = Theme().visitorCode,
                visitorCode: String = "11111",
                isPoweredByShown: Bool = true

            ) {
                self.viewType = viewType
                self.style = style
                self.visitorCode = visitorCode
                self.isPoweredByShown = isPoweredByShown
            }
        }

        var props: Props = Props() {
            didSet {
                renderProps()
            }
        }

        private let titleLabel = UILabel().make { label in
            label.numberOfLines = 0
            label.textAlignment = .center
        }

        private lazy var stackView = UIStackView.make(.vertical, spacing: 24)(
            titleLabel,
            visitorCodeStack,
            poweredBy
        )

        private lazy var closeButton = Button(
            kind: .visitorCodeClose,
            tap: { [weak self] in
                self?.props.closeButtonTap?()
            }
        ).make { button in
            button.accessibilityIdentifier = "visitorCode_alert_close_button"
        }

        private lazy var poweredBy: PoweredBy = PoweredBy(style: props.style.poweredBy)
        private lazy var visitorCodeStack = UIStackView.make(.horizontal, spacing: 8)()
        private let contentInsets = UIEdgeInsets(top: 24, left: 24, bottom: 21, right: 24)

        override func setup() {
            super.setup()
            clipsToBounds = true
            layer.masksToBounds = false
            layer.cornerRadius = props.style.cornerRadius
            renderProps()
        }

        override func defineLayout() {
            super.defineLayout()
            addSubview(stackView)
            addSubview(closeButton)
            visitorCodeStack.distribution = .fill
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom),
                stackView.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
                closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
                closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -26)
            ])
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            switch props.style.backgroundColor {
            case .fill(let color):
                backgroundColor = color
            case .gradient(let colors):
                makeGradientBackground(
                    colors: colors,
                    cornerRadius: props.style.cornerRadius
                )
            }
            layer.shadowPath = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(
                    width: props.style.cornerRadius,
                    height: props.style.cornerRadius
                )
            ).cgPath
        }

        func renderProps() {
            titleLabel.font = props.style.titleFont
            titleLabel.textColor = props.style.titleColor
            titleLabel.text = L10n.Alert.VisitorCode.title
            setFontScalingEnabled(
                props.style.accessibility.isFontScalingEnabled,
                for: titleLabel
            )
            renderedVisitorCode = props.visitorCode
            poweredBy.alpha = props.isPoweredByShown ? 1 : 0
            renderShadow()

            switch props.style.closeButtonColor {
            case .fill(let color):
                closeButton.tintColor = color
            case .gradient(let colors):
                closeButton.makeGradientBackground(colors: colors)
            }

            closeButton.isHidden = props.closeButtonTap == nil
        }

        var renderedVisitorCode: String = "" {
            didSet {
                guard renderedVisitorCode != oldValue else { return }
                visitorCodeStack.removeArrangedSubviews()
                renderedVisitorCode.forEach { char in
                    let valueLabel = NumberView().make { numberView in
                        numberView.props = .init(character: char, style: props.style)
                    }
                    visitorCodeStack.addArrangedSubview(valueLabel)
                }
            }
        }

        func renderShadow() {
            layer.shadowColor = props.isShadowNeeded
                            ? UIColor.black.withAlphaComponent(0.16).cgColor
                            : UIColor.clear.cgColor
            layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
            layer.shadowRadius = 24.0
            layer.shadowOpacity = 1.0
        }
    }
}

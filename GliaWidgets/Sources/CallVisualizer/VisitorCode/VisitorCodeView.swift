import UIKit

extension CallVisualizer {
    final class VisitorCodeView: BaseView {
        struct Props: Equatable {
            enum ViewType: Equatable {
                case alert(closeButtonTap: Cmd)
                case embedded
            }
            enum ViewState: Equatable {
                case error(refreshTap: Cmd)
                case loading
                case success(visitorCode: String)
            }
            let viewState: ViewState
            let viewType: ViewType
            let style: VisitorCodeStyle
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

            var refreshButtonTap: Cmd? {
                switch viewState {
                case let .error(refreshButtonTap):
                    return refreshButtonTap
                case .loading, .success:
                    return nil
                }
            }

            var titleAccessibilityIdentifier: String {
                switch viewType {
                case .alert:
                    return "visitor_code_alert_title_label"
                case .embedded:
                    return "visitor_code_embedded_view_title_label"
                }
            }

            init(
                viewType: ViewType = .alert(closeButtonTap: .nop),
                viewState: ViewState = .loading,
                style: VisitorCodeStyle = Theme().visitorCode,
                isPoweredByShown: Bool = true

            ) {
                self.viewType = viewType
                self.style = style
                self.isPoweredByShown = isPoweredByShown
                self.viewState = viewState
            }
        }

        var props: Props = Props() {
            didSet {
                renderProps()
            }
        }

        let refreshButton = UIButton().make { button in
            button.accessibilityIdentifier = "visitor_code_refresh_button"
            button.accessibilityTraits = .button
            button.accessibilityLabel = Localization.CallVisualizer.VisitorCode.Refresh.Accessibility.label
            button.accessibilityHint = Localization.CallVisualizer.VisitorCode.Refresh.Accessibility.hint
        }
        let spinnerView = UIImageView().make { imageView in
            imageView.image = Asset.spinner.image.withRenderingMode(.alwaysTemplate)
            imageView.contentMode = .center
        }

        let titleLabel = UILabel().make { label in
            label.numberOfLines = 2
            label.textAlignment = .center
            label.accessibilityIdentifier = "visitor_code_title_label"
        }

        lazy var stackView = UIStackView.make(.vertical, spacing: 24)(
            titleLabel,
            poweredBy
        )

        lazy var closeButton = Button(
            kind: .visitorCodeClose,
            tap: { [weak self] in
                self?.props.closeButtonTap?()
            }
        ).make { button in
            button.accessibilityIdentifier = "visitor_code_alert_close_button"
            button.accessibilityTraits = .button
            button.accessibilityLabel = Localization.General.Close.accessibility
            button.accessibilityHint = Localization.CallVisualizer.VisitorCode.Close.Accessibility.hint
        }

        lazy var poweredBy: PoweredBy = PoweredBy(style: props.style.poweredBy)
        lazy var visitorCodeStack = UIStackView.make(.horizontal, spacing: 8)()
        private let contentInsets = UIEdgeInsets(top: 24, left: 24, bottom: 21, right: 24)

        override func setup() {
            super.setup()
            clipsToBounds = true
            layer.masksToBounds = false
            renderProps()
            refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
            accessibilityElements = [titleLabel, closeButton, visitorCodeStack, poweredBy, refreshButton]
        }

        override func defineLayout() {
            super.defineLayout()

            var constraints = [NSLayoutConstraint](); defer { constraints.activate() }

            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            constraints += stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left)
            constraints += stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right)
            constraints += stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)
            constraints += stackView.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top)

            addSubview(closeButton)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            constraints += closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30)
            constraints += closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -26)

            refreshButton.translatesAutoresizingMaskIntoConstraints = false
            constraints += refreshButton.heightAnchor.constraint(equalToConstant: 40)
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

            refreshButton.layer.cornerRadius = props.style.actionButton.cornerRaidus ?? 9
            refreshButton.layer.borderWidth = props.style.actionButton.borderWidth ?? 0
            refreshButton.layer.borderColor = props.style.actionButton.borderColor?.cgColor
            refreshButton.layer.shadowColor = props.style.actionButton.shadowColor?.cgColor
            refreshButton.layer.shadowOffset = props.style.actionButton.shadowOffset ?? .zero
            refreshButton.layer.shadowRadius = props.style.actionButton.shadowRadius ?? 0.0
            refreshButton.layer.shadowOpacity = props.style.actionButton.shadowOpacity ?? 0
            refreshButton.setTitle(props.style.actionButton.title, for: .normal)
            refreshButton.titleLabel?.font = props.style.actionButton.titleFont
            switch props.style.actionButton.backgroundColor {
            case .fill(let color):
                refreshButton.backgroundColor = color
            case .gradient(let colors):
                refreshButton.makeGradientBackground(
                    colors: colors,
                    cornerRadius: props.style.actionButton.cornerRaidus
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

        var renderedVisitorCode: String = "" {
            didSet {
                guard renderedVisitorCode != oldValue else { return }
                visitorCodeStack.removeArrangedSubviews()
                renderedVisitorCode.enumerated().forEach { index, char in
                    let valueLabel = NumberView().make { numberView in
                        numberView.props = .init(character: char, style: props.style.numberSlot)
                        numberView.accessibilityIdentifier = "visitor_code_number_slot_at_index_\(index)"
                        numberView.accessibilityLabel = "\(char)"
                    }
                    visitorCodeStack.addArrangedSubview(valueLabel)
                }
            }
        }

        func renderVisitorCode() {
            switch shouldReplaceViewInStack() {
            case true:
                stackView.replaceArrangedSubview(at: 1, with: visitorCodeStack)
            case false:
                stackView.insertArrangedSubview(visitorCodeStack, at: 1)
            }
        }

        func renderError() {
            switch shouldReplaceViewInStack() {
            case true:
                stackView.replaceArrangedSubview(at: 1, with: refreshButton)
            case false:
                stackView.insertArrangedSubview(refreshButton, at: 1)
            }
        }

        func renderSpinner() {
            switch shouldReplaceViewInStack() {
            case true:
                stackView.replaceArrangedSubview(at: 1, with: spinnerView)
            case false:
                stackView.insertArrangedSubview(spinnerView, at: 1)
            }
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = CGFloat.pi * 2
            rotation.duration = 1.0
            rotation.repeatCount = Float.infinity
            spinnerView.tintColor = props.style.loadingProgressColor
            spinnerView.layer.add(rotation, forKey: "Spin")
        }

        func renderShadow() {
            layer.shadowColor = props.isShadowNeeded
                            ? UIColor.black.withAlphaComponent(0.16).cgColor
                            : UIColor.clear.cgColor
            layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
            layer.shadowRadius = 24.0
            layer.shadowOpacity = 1.0
        }

        func shouldReplaceViewInStack() -> Bool {
            guard !stackView.arrangedSubviews.contains(spinnerView) else { return true }
            guard !stackView.arrangedSubviews.contains(visitorCodeStack) else { return true }
            guard !stackView.arrangedSubviews.contains(refreshButton) else { return true }
            return false
        }

        @objc func refreshButtonTapped(_ sender: UIButton) {
            self.props.refreshButtonTap?()
        }
    }
}

// Props rendering
extension CallVisualizer.VisitorCodeView {
    func renderProps() {
        titleLabel.accessibilityIdentifier = props.titleAccessibilityIdentifier
        layer.cornerRadius = props.style.cornerRadius
        layer.borderColor = props.style.borderColor.cgColor
        layer.borderWidth = props.style.borderWidth

        titleLabel.font = props.style.titleFont
        titleLabel.textColor = props.style.titleColor
        switch props.viewState {
        case .success(visitorCode: let code):
            renderedVisitorCode = code
            titleLabel.text = Localization.CallVisualizer.VisitorCode.title
            renderVisitorCode()
            titleLabel.accessibilityHint = Localization.CallVisualizer.VisitorCode.Title.Accessibility.hint
        case .error:
            titleLabel.text = Localization.VisitorCode.failed
            renderError()
            titleLabel.accessibilityHint = nil
        case .loading:
            titleLabel.text = Localization.CallVisualizer.VisitorCode.title
            renderSpinner()
        }
        setFontScalingEnabled(
            props.style.accessibility.isFontScalingEnabled,
            for: titleLabel
        )
        setFontScalingEnabled(
            props.style.accessibility.isFontScalingEnabled,
            for: refreshButton
        )
        poweredBy.alpha = props.isPoweredByShown ? 1 : 0
        renderShadow()

        switch props.style.closeButtonColor {
        case .fill(let color):
            closeButton.tintColor = color
        case .gradient(let colors):
            closeButton.makeGradientBackground(colors: colors)
        }

        closeButton.isHidden = props.closeButtonTap == nil

        layoutSubviews()
    }
}

import UIKit

extension Survey {
    final class ContentView: BaseView {

        // MARK: - Survey questions container

        lazy var header = UILabel().make {
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        let scrollView = UIScrollView().makeView {
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        lazy var surveyItemsStack = UIStackView.make(.vertical, spacing: 24)()
        lazy var contentContainerStackView = UIStackView.make(.vertical, spacing: 24)(
            header,
            surveyItemsStack
        )

        // MARK: - Button container

        private let buttonTitleInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

        let buttonContainer = UIView().makeView {
            $0.layer.masksToBounds = false
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.15
            $0.layer.shadowOffset = .zero
            $0.layer.shadowRadius = 8
        }
        let cancelButton = UIButton(type: .custom).make {
            $0.setTitle(Localization.General.cancel, for: .normal)
            $0.titleLabel?.numberOfLines = 0
            // Using `byWordWrapping` prevents button text
            // from getting truncated, for example for large
            // dynamic font types.
            $0.titleLabel?.lineBreakMode = .byWordWrapping
        }
        let submitButton = UIButton(type: .custom).make {
            $0.setTitle(Localization.General.submit, for: .normal)
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.lineBreakMode = .byWordWrapping
        }
        lazy var buttonStackView = UIStackView.make(.horizontal, spacing: 16)(
            cancelButton,
            submitButton
        ).makeView()

        var endEditing: () -> Void = {}

        override func setup() {
            super.setup()

            addSubview(scrollView)
            scrollView.addSubview(contentContainerStackView)

            buttonContainer.addSubview(buttonStackView)
            addSubview(buttonContainer)
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapToHideKeyboard)))
        }

        @objc
        private func tapToHideKeyboard(gesture: UITapGestureRecognizer) {
            endEditing()
        }

        override func defineLayout() {
            super.defineLayout()
            backgroundColor = .black.withAlphaComponent(0.8)
            cancelButton.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
            submitButton.titleLabel?.translatesAutoresizingMaskIntoConstraints = false

            var constraints: [NSLayoutConstraint] = []; defer { constraints.activate() }
            constraints += scrollView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor)
            constraints += scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
            constraints += scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
            constraints += scrollView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor)
            constraints += scrollView.frameLayoutGuide.heightAnchor.constraint(
                equalTo: contentContainerStackView.heightAnchor,
                constant: Self.contentPadding * 2
            ).priority(.defaultLow)
            constraints += contentContainerStackView.topAnchor.constraint(
                equalTo: scrollView.topAnchor,
                constant: Self.contentPadding
            )
            constraints += contentContainerStackView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: Self.contentPadding
            )
            constraints += contentContainerStackView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -Self.contentPadding
            )
            constraints += contentContainerStackView.heightAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.heightAnchor,
                constant: -2 * Self.contentPadding
            )

            constraints += buttonContainer.bottomAnchor.constraint(equalTo: bottomAnchor).identifier(.bottom)
            constraints += buttonContainer.leadingAnchor.constraint(equalTo: leadingAnchor)
            constraints += buttonContainer.trailingAnchor.constraint(equalTo: trailingAnchor)
            constraints += buttonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Self.contentPadding)
            constraints += buttonStackView.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: Self.contentPadding)
            constraints += buttonStackView.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: Self.contentPadding)
            constraints += buttonStackView.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: -Self.contentPadding)
            constraints += cancelButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
            constraints += submitButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
            constraints += cancelButton.widthAnchor.constraint(lessThanOrEqualTo: submitButton.widthAnchor)
            constraints += submitButton.widthAnchor.constraint(lessThanOrEqualTo: cancelButton.widthAnchor)

            constraints += constraintsForTitleLabel(of: cancelButton, withInsets: buttonTitleInsets)
            constraints += constraintsForTitleLabel(of: submitButton, withInsets: buttonTitleInsets)
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            _updateUi?()
        }
        func showKeyboard(keyboardHeight: CGFloat) {
            constraints.constraints(with: .bottom).first?.constant = -keyboardHeight
        }
        func hideKeyboard() {
            constraints.constraints(with: .bottom).first?.constant = 0
        }

        var _updateUi: (() -> Void)?
        func updateUi(theme: Theme) {

            _updateUi = { [weak self] in
                guard let this = self else { return }
                this.header.font = theme.survey.title.font
                this.header.textColor = .init(hex: theme.survey.title.color)
                this.header.textAlignment = theme.survey.title.alignment
                theme.survey.layer.background.map { type in
                    switch type {
                    case .fill(color: let color):
                        this.scrollView.backgroundColor = color
                        this.buttonContainer.backgroundColor = color
                    case .gradient(colors: let colors):
                        this.scrollView.layer.insertSublayer(this.makeGradientBackground(colors: colors), at: 0)
                        this.buttonContainer.layer.insertSublayer(this.makeGradientBackground(colors: colors), at: 0)
                    }
                }
                this.scrollView.layer.cornerRadius = theme.survey.layer.cornerRadius

                this.cancelButton.update(with: theme.survey.cancelButton)
                this.submitButton.update(with: theme.survey.submitButton)
                this.cancelButton.accessibilityLabel = theme.survey.cancelButton.accessibility.label
                this.submitButton.accessibilityLabel = theme.survey.submitButton.accessibility.label

                this.header.accessibilityTraits = .header

                setFontScalingEnabled(
                    theme.survey.accessibility.isFontScalingEnabled,
                    for: this.header
                )
                setFontScalingEnabled(
                    theme.survey.accessibility.isFontScalingEnabled,
                    for: this.cancelButton
                )
                setFontScalingEnabled(
                    theme.survey.accessibility.isFontScalingEnabled,
                    for: this.submitButton
                )
            }
            setNeedsLayout()
        }

        // MARK: - Private

        private static let contentPadding: CGFloat = 24

        private func constraintsForTitleLabel(of button: UIButton, withInsets insets: UIEdgeInsets) -> [NSLayoutConstraint] {
            guard let titleLabel = button.titleLabel else { return [] }
            return [
                titleLabel.topAnchor.constraint(greaterThanOrEqualTo: button.topAnchor, constant: insets.top),
                titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: button.bottomAnchor, constant: -insets.bottom),
                titleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: insets.left),
                titleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -insets.right)
            ]
        }
    }
}

extension NSAttributedString {
    static func withRequiredSymbol(
        foregroundColor: UIColor,
        font: UIFont,
        isRequired: Bool,
        text: String
    ) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(
            string: text,
            attributes: [
                .foregroundColor: foregroundColor,
                .font: font
            ]
        )
        if isRequired {
            mutableString.append(
                .init(
                    string: "*",
                    attributes: [
                        .foregroundColor: UIColor.red,
                        .font: font
                    ]
                )
            )
        }
        return mutableString
    }
}

extension UIButton {
    func update(with style: Theme.Button) {
        switch style.background {
        case .fill(let color):
            backgroundColor = color
        case .gradient(let colors):
            makeGradientBackground(colors: colors, cornerRadius: style.cornerRadius)
        }
        contentEdgeInsets = .init(top: 6, left: 16, bottom: 6, right: 16)
        clipsToBounds = true
        layer.masksToBounds = false
        layer.cornerRadius = style.cornerRadius

        style.borderColor.unwrap { layer.borderColor = UIColor(hex: $0).cgColor }
        layer.borderWidth = style.borderWidth

        layer.shadowColor = UIColor(hex: style.shadow.color).cgColor
        layer.shadowOffset = style.shadow.offset
        layer.shadowOpacity = style.shadow.opacity
        layer.shadowRadius = style.shadow.radius

        titleLabel?.font = style.title.font
        setTitleColor(.init(hex: style.title.color), for: .normal)
        titleLabel?.textAlignment = .center
    }
}

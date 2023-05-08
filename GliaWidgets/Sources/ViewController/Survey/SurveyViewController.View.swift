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

        let buttonContainer = UIView().makeView {
            $0.layer.masksToBounds = false
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.15
            $0.layer.shadowOffset = .zero
            $0.layer.shadowRadius = 8
        }
        let cancelButton = UIButton(type: .custom).make {
            $0.setTitle(L10n.Survey.Action.cancel, for: .normal)
            $0.titleLabel?.numberOfLines = 0
            // Using `byWordWrapping` prevents button text
            // from getting truncated, for example for large
            // dynamic font types.
            $0.titleLabel?.lineBreakMode = .byWordWrapping
        }
        let submitButton = UIButton(type: .custom).make {
            $0.setTitle(L10n.Survey.Action.submit, for: .normal)
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

            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor),

                scrollView.frameLayoutGuide.heightAnchor.constraint(
                    equalTo: contentContainerStackView.heightAnchor,
                    constant: Self.contentPadding * 2
                ).priority(.defaultLow),

                contentContainerStackView.topAnchor.constraint(
                    equalTo: scrollView.topAnchor,
                    constant: Self.contentPadding
                ),
                contentContainerStackView.leadingAnchor.constraint(
                    equalTo: scrollView.leadingAnchor,
                    constant: Self.contentPadding
                ),
                contentContainerStackView.trailingAnchor.constraint(
                    equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                    constant: -Self.contentPadding
                ),
                contentContainerStackView.heightAnchor.constraint(
                    equalTo: scrollView.contentLayoutGuide.heightAnchor,
                    constant: -2 * Self.contentPadding
                ),

                buttonContainer.bottomAnchor.constraint(equalTo: bottomAnchor).identifier(.bottom),
                buttonContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                buttonContainer.trailingAnchor.constraint(equalTo: trailingAnchor),

                buttonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Self.contentPadding),
                buttonStackView.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: Self.contentPadding),
                buttonStackView.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: Self.contentPadding),
                buttonStackView.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: -Self.contentPadding),

                cancelButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
                submitButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
                cancelButton.widthAnchor.constraint(lessThanOrEqualTo: submitButton.widthAnchor),
                submitButton.widthAnchor.constraint(lessThanOrEqualTo: cancelButton.widthAnchor)
            ])
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

                this.cancelButton.update(with: theme.survey.cancellButton)
                this.submitButton.update(with: theme.survey.submitButton)
                this.cancelButton.accessibilityLabel = theme.survey.cancellButton.accessibility.label
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
                    string: L10n.Survey.Question.Title.asterisk,
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

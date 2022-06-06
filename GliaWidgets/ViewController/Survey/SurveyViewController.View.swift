import UIKit

extension Survey {
    final class ContentView: View {

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
        }
        let submitButton = UIButton(type: .custom).make {
            $0.setTitle(L10n.Survey.Action.submit, for: .normal)
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

                cancelButton.heightAnchor.constraint(equalToConstant: 44),
                submitButton.heightAnchor.constraint(equalToConstant: 44),
                cancelButton.widthAnchor.constraint(equalTo: submitButton.widthAnchor)
            ])
        }

        func showKeyboard(keyboardHeight: CGFloat) {
            constraints.constraints(with: .bottom).first?.constant = -keyboardHeight
        }
        func hideKeyboard() {
            constraints.constraints(with: .bottom).first?.constant = 0
        }

        func updateUi(theme: Theme) {
            header.font = .systemFont(
                ofSize: theme.survey.title.fontSize,
                weight: .init(rawValue: theme.survey.title.fontWeight)
            )
            header.textColor = .init(hex: theme.survey.title.color)
            header.textAlignment = theme.survey.title.alignment
            if let hex = theme.survey.layer.background {
                scrollView.backgroundColor = .init(hex: hex)
                buttonContainer.backgroundColor = .init(hex: hex)
            }
            scrollView.layer.cornerRadius = theme.survey.layer.cornerRadius

            cancelButton.update(with: theme.survey.cancellButton)
            submitButton.update(with: theme.survey.submitButton)
        }

        // MARK: - Private

        private static let contentPadding: CGFloat = 24
    }
}

extension NSAttributedString {
    static func withRequiredSymbol(
        foregroundColor: UIColor,
        fontSize: CGFloat,
        fontWeight: CGFloat,
        isRequired: Bool,
        text: String
    ) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(
            string: text,
            attributes: [
                .foregroundColor: foregroundColor,
                    .font: UIFont.systemFont(ofSize: fontSize, weight: .init(fontWeight))
            ]
        )
        if isRequired {
            mutableString.append(.init(string: " *", attributes: [.foregroundColor: UIColor.red]))
        }
        return mutableString
    }
}

extension UIButton {
    func update(with style: Theme.Button) {
        style.background.map { backgroundColor = UIColor(hex: $0) }
        contentEdgeInsets = .init(top: 6, left: 16, bottom: 6, right: 16)
        clipsToBounds = true
        layer.masksToBounds = false
        layer.cornerRadius = style.cornerRadius

        style.borderColor.map { layer.borderColor = UIColor(hex: $0).cgColor }
        layer.borderWidth = style.borderWidth

        layer.shadowColor = UIColor(hex: style.shadow.color).cgColor
        layer.shadowOffset = style.shadow.offset
        layer.shadowOpacity = style.shadow.opacity
        layer.shadowRadius = style.shadow.radius

        titleLabel?.font = .systemFont(ofSize: style.title.fontSize, weight: .init(style.title.fontWeight))
        setTitleColor(.init(hex: style.title.color), for: .normal)
        titleLabel?.textAlignment = .center
    }
}

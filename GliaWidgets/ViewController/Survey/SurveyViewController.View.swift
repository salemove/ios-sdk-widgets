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
            $0.setTitle("Cancel", for: .normal)
        }
        let submitButton = UIButton(type: .custom).make {
            $0.setTitle("Submit", for: .normal)
        }
        lazy var buttonStackView = UIStackView.make(.horizontal, spacing: 16)(
            cancelButton,
            submitButton
        ).makeView()

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
            endEditing(true)
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
            header.font = .systemFont(ofSize: theme.survey.title.fontSize)
            if let hex = theme.survey.layer.background {
                scrollView.backgroundColor = .init(hex: hex)
                buttonContainer.backgroundColor = .init(hex: hex)
            }
            scrollView.layer.cornerRadius = theme.survey.layer.cornerRadius
            cancelButton.backgroundColor = .init(hex: theme.survey.cancellButton.background)
            cancelButton.layer.cornerRadius = theme.survey.cancellButton.cornerRadius
            cancelButton.titleLabel?.font = .systemFont(
                ofSize: theme.survey.cancellButton.title.fontSize,
                weight: .init(rawValue: theme.survey.cancellButton.title.fontWeight)
            )
            cancelButton.setTitleColor(.init(hex: theme.survey.cancellButton.title.color), for: .normal)

            submitButton.backgroundColor = .init(hex: theme.survey.submitButton.background)
            submitButton.layer.cornerRadius = theme.survey.submitButton.cornerRadius
            submitButton.titleLabel?.font = .systemFont(
                ofSize: theme.survey.submitButton.title.fontSize,
                weight: .init(theme.survey.submitButton.title.fontWeight)
            )
            submitButton.setTitleColor(.init(hex: theme.survey.submitButton.title.color), for: .normal)
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

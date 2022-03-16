import UIKit

extension Survey {
    final class ContentView: View {

        // MARK: - Survey questions container

        let header = UILabel().make {
            $0.font = .systemFont(ofSize: 24)
            $0.text = "🤷‍♂️"
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        let scrollView = UIScrollView().makeView {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 30
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        lazy var surveyItemsStack = UIStackView.make(.vertical, spacing: 24)()
        lazy var contentContainerStackView = UIStackView.make(.vertical, spacing: 24)(
            header,
            surveyItemsStack
        )

        // MARK: - Button container

        let buttonContainer = UIView().makeView {
            $0.backgroundColor = .white
            $0.layer.masksToBounds = false
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.15
            $0.layer.shadowOffset = .zero
            $0.layer.shadowRadius = 8
        }
        let cancelButton = UIButton(type: .custom).make {
            $0.setTitle("Cancel", for: .normal)
            $0.backgroundColor = .init(hex: "#D11149")
            $0.titleLabel?.font = .systemFont(ofSize: 16)
            $0.layer.cornerRadius = 4
        }
        let submitButton = UIButton(type: .custom).make {
            $0.setTitle("Submit", for: .normal)
            $0.backgroundColor = .init(hex: "#0F6BFF")
            $0.titleLabel?.font = .systemFont(ofSize: 16)
            $0.layer.cornerRadius = 4
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

        // MARK: - Private

        private static let contentPadding: CGFloat = 24
    }
}

extension NSAttributedString {
    static func withRequiredSymbol(isRequired: Bool, text: String) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(string: text)
        if isRequired {
            mutableString.append(.init(string: " *", attributes: [.foregroundColor: UIColor.red]))
        }
        return mutableString
    }
}

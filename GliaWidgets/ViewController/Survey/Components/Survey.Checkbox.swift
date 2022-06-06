import UIKit

extension Survey {
    final class CheckboxView: View {

        enum State {
            case active, highlighted, selected
        }

        struct Props {
            let title: String
            let state: State
            let onSelection: () -> Void

            init(
                title: String = "",
                state: State = .active,
                onSelection: @escaping () -> Void = {}
            ) {
                self.title = title
                self.state = state
                self.onSelection = onSelection
            }
        }

        let imageViewContainer = UIView()
        let imageView = UIImageView().makeView {
            $0.image = Asset.surveyCheckbox.image
        }
        let checkImageView = UIImageView().makeView {
            $0.image = Asset.surveyCheckboxChecked.image
        }
        let value = UILabel().makeView {
            $0.numberOfLines = 0
        }
        lazy var contentStack = UIStackView.make(.horizontal, spacing: 8)(
            imageViewContainer,
            value
        )

        var props: Props { didSet { render() } }

        init(
            props: Props = .init(),
            style: Theme.Text,
            checkedTintColor: UIColor
        ) {
            self.props = props
            self.style = style
            self.checkedTintColor = checkedTintColor
            super.init()
        }

        override func setup() {
            super.setup()

            addSubview(contentStack)
            imageViewContainer.addSubview(imageView)
            imageView.addSubview(checkImageView)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
            addGestureRecognizer(gesture)

            render()
        }

        override func defineLayout() {
            super.defineLayout()

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
                imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
                checkImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                checkImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                imageView.topAnchor.constraint(equalTo: imageViewContainer.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: imageViewContainer.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: imageViewContainer.trailingAnchor),
                imageView.trailingAnchor.constraint(lessThanOrEqualTo: imageViewContainer.trailingAnchor),

                contentStack.topAnchor.constraint(equalTo: topAnchor),
                contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        func render() {
            value.text = props.title
            switch props.state {
            case .selected:
                checkImageView.image = Asset.surveyCheckboxChecked.image
            case .active:
                checkImageView.image = nil
            case .highlighted:
                checkImageView.image = Asset.surveyCheckboxChecked.image
            }
            value.font = .systemFont(ofSize: style.fontSize, weight: .init(style.fontWeight))
            value.textColor = .init(hex: style.color)
            checkImageView.tintColor = checkedTintColor
        }

        // MARK: - Private

        private let style: Theme.Text
        private let checkedTintColor: UIColor

        @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
            props.onSelection()
        }
    }
}

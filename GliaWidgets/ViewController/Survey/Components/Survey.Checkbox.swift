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

        let imageView = UIImageView().make {
            $0.image = Asset.surveyCheckbox.image
        }
        let value = UILabel().makeView {
            $0.numberOfLines = 0
        }
        lazy var contentStack = UIStackView.make(.horizontal, spacing: 8)(
            imageView,
            value
        )

        var props: Props { didSet { render() } }

        init(
            props: Props = .init(),
            style: Theme.Text
        ) {
            self.props = props
            self.style = style
            super.init()
        }

        override func setup() {
            super.setup()

            addSubview(contentStack)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
            addGestureRecognizer(gesture)

            render()
        }

        override func defineLayout() {
            super.defineLayout()

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 24),
                imageView.heightAnchor.constraint(equalToConstant: 24),

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
                imageView.image = Asset.surveyCheckboxChecked.image
            case .active:
                imageView.image = Asset.surveyCheckbox.image
            case .highlighted:
                imageView.image = Asset.surveyCheckboxChecked.image
            }
            value.font = .systemFont(ofSize: style.fontSize, weight: .init(style.fontWeight))
            value.textColor = .init(hex: style.color)
        }

        // MARK: - Private

        private let style: Theme.Text

        @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
            props.onSelection()
        }
    }
}

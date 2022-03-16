import UIKit

extension Survey {
    final class ButtonView: View {

        enum State {
            case active, highlighted, selected
        }

        struct Props {
            let title: String
            let state: State
            let onSelection: () -> Void
        }

        let value = UILabel().makeView {
            $0.clipsToBounds = true
            $0.textAlignment = .center
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.gray.cgColor
        }

        var props: Props { didSet { render() } }

        init(props: Props = .init(title: "", state: .active, onSelection: {})) {
            self.props = props
            super.init()
        }

        override func setup() {
            super.setup()

            addSubview(value)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
            addGestureRecognizer(gesture)

            render()
        }

        override func defineLayout() {
            super.defineLayout()
            NSLayoutConstraint.activate([
                value.topAnchor.constraint(equalTo: topAnchor, constant: 1),
                value.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
                value.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
                value.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1)
            ])
        }

        func render() {
            value.text = props.title
            switch props.state {
            case .active:
                value.layer.borderColor = UIColor.blue.cgColor
                value.backgroundColor = .clear
                value.textColor = .black
            case .highlighted:
                value.layer.borderColor = UIColor.red.cgColor
                value.backgroundColor = .clear
                value.textColor = .red
            case .selected:
                value.layer.borderColor = UIColor.blue.cgColor
                value.backgroundColor = UIColor.blue
                value.textColor = .white
            }
        }

        // MARK: - Private

        @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
            props.onSelection()
        }
    }
}

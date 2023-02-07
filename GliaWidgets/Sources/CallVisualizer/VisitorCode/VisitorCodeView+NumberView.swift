import UIKit

extension CallVisualizer.VisitorCodeView {
    final class NumberView: UILabel {
        struct Props: Equatable {
            let character: Character
            let style: NumberSlotStyle
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.numberOfLines = 0
            self.clipsToBounds = true
            self.textAlignment = .center
            NSLayoutConstraint.activate([
                self.heightAnchor.constraint(equalToConstant: 60),
                self.widthAnchor.constraint(equalToConstant: 55).priority(.defaultHigh)
            ])
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var props: Props = Props(character: " ", style: Theme().visitorCode.numberSlot) {
            didSet {
                renderProps()
            }
        }

        private func renderProps() {
            text = String(props.character)
            font = props.style.numberFont
            textColor = props.style.numberColor
            layer.cornerRadius = props.style.cornerRadius
            layer.borderWidth = props.style.borderWidth
            layer.borderColor = props.style.borderColor.cgColor

            switch props.style.backgroundColor {
            case .fill(let color):
                backgroundColor = color
            case .gradient(let colors):
                makeGradientBackground(
                    colors: colors,
                    cornerRadius: props.style.cornerRadius
                )
            }
        }
    }
}

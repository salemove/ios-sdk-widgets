import UIKit

extension CallVisualizer.VisitorCodeView {
    class NumberView: UILabel {
        struct Props: Equatable {
            let character: Character
            let style: VisitorCodeStyle
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.font = .boldSystemFont(ofSize: 40)
            self.numberOfLines = 0
            self.textColor = props.style.numberSlot.numberColor
            self.textAlignment = .center
            switch props.style.numberSlot.backgroundColor {
            case .fill(let color):
                self.backgroundColor = color
            case .gradient(let colors):
                makeGradientBackground(
                    colors: colors,
                    cornerRadius: props.style.numberSlot.cornerRadius
                )
            }
            self.layer.cornerRadius = props.style.numberSlot.cornerRadius
            self.layer.borderWidth = props.style.numberSlot.borderWidth
            self.layer.borderColor = props.style.numberSlot.borderColor.cgColor
            NSLayoutConstraint.activate([
                self.heightAnchor.constraint(equalToConstant: 60),
                self.widthAnchor.constraint(equalToConstant: 55).priority(.defaultHigh)
            ])
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var props: Props = Props(character: " ", style: Theme().visitorCode) {
            didSet {
                renderProps()
            }
        }

        func renderProps() {
            text = String(props.character)
        }
    }
}

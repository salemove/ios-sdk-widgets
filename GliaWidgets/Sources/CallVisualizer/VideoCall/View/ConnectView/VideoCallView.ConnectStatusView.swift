import UIKit

extension CallVisualizer.VideoCallView {
    final class ConnectStatusView: BaseView {
        // MARK: - Properties

        var props: Props = Props() {
            didSet {
                renderProps()
            }
        }

        private var renderFirstText: Props.LabelText = "" {
            didSet {
                guard renderFirstText != oldValue else { return }
                setText(
                    text: renderFirstText.text,
                    to: firstLabel,
                    animated: renderFirstText.animated
                )
            }
        }

        private var renderSecondText: Props.LabelText = "" {
            didSet {
                guard renderSecondText != oldValue else { return }
                setText(
                    text: renderSecondText.text,
                    to: secondLabel,
                    animated: renderSecondText.animated
                )
            }
        }

        private lazy var stackView = UIStackView().make {
            $0.axis = .vertical
            $0.spacing = 8
        }

        private lazy var firstLabel = UILabel().make {
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }

        private lazy var secondLabel = UILabel().make {
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.accessibilityIdentifier = "call_duration_label"
        }

        override func setup() {
            super.setup()
            addSubview(stackView)
            stackView.addArrangedSubviews([firstLabel, secondLabel])
            stackView.layoutInSuperview().activate()
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallView.ConnectStatusView {
    struct Props: Equatable {
        let style: ConnectStatusStyle
        let firstLabelText: LabelText
        let secondLabelText: LabelText

        init(
            style: ConnectStatusStyle = Theme().callStyle.connect.connecting,
            firstLabelText: LabelText = "",
            secondLabelText: LabelText = ""
        ) {
            self.style = style
            self.firstLabelText = firstLabelText
            self.secondLabelText = secondLabelText
        }
    }
}

extension CallVisualizer.VideoCallView.ConnectStatusView.Props {
    struct LabelText: Equatable {
        let text: String?
        let animated: Bool
    }
}

extension CallVisualizer.VideoCallView.ConnectStatusView.Props.LabelText: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        text = value
        animated = false
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallView.ConnectStatusView {
    func renderProps() {
        renderFirstText = props.firstLabelText
        renderSecondText = props.secondLabelText
        setStyle(props.style)
    }

    func setStyle(_ style: ConnectStatusStyle) {
        firstLabel.font = style.firstTextFont
        firstLabel.textColor = style.firstTextFontColor
        firstLabel.accessibilityHint = style.accessibility.firstTextHint

        secondLabel.font = style.secondTextFont
        secondLabel.textColor = style.secondTextFontColor
        secondLabel.accessibilityHint = style.accessibility.secondTextHint

        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: firstLabel
        )
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: secondLabel
        )
    }

    func setText(text: String?, to label: UILabel, animated: Bool) {
        label.text = text

        if animated {
            label.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.7,
                options: .curveEaseInOut,
                animations: {
                    label.transform = .identity
                },
                completion: nil
            )
        }
    }
}

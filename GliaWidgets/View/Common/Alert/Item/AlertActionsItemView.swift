import UIKit
import PureLayout

final class AlertActionsItemView: UIView {
    private let stackView = UIStackView()

    private let actions: [AlertAction]
    private let buttons: [AlertButton]

    init(
        actions: [AlertAction],
        alertStyle: AlertStyle
    ) {
        self.actions = actions
        self.buttons = actions.map({
            AlertButton(
                action: $0,
                alertStyle: alertStyle
            )
        })

        super.init(frame: .zero)

        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        stackView.distribution = .fillEqually
        stackView.spacing = 10
    }

    private func layout() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        buttons.forEach(stackView.addArrangedSubview(_:))
    }
}

private final class AlertButton: UIButton {
    private let action: AlertAction
    private let alertStyle: AlertStyle

    init(
        action: AlertAction,
        alertStyle: AlertStyle
    ) {
        self.action = action
        self.alertStyle = alertStyle

        super.init(frame: .zero)

        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        // TODO: alertStyle border + shadow etc
        switch action.style {
        case .regular:
            setBackgroundImage(alertStyle.positiveAction.backgroundColor.pixelImage, for: .normal)
            setTitleColor(alertStyle.positiveAction.titleColor, for: .normal)
            titleLabel?.font = alertStyle.positiveAction.titleFont

        case .destructive:
            setBackgroundImage(alertStyle.negativeAction.backgroundColor.pixelImage, for: .normal)
            setTitleColor(alertStyle.negativeAction.titleColor, for: .normal)
            titleLabel?.font = alertStyle.negativeAction.titleFont
        }

        setTitle(action.title, for: .normal)

        clipsToBounds = true
        layer.cornerRadius = 4
        contentEdgeInsets = .horizontal(16) + .vertical(12)

        addTarget(
            self,
            action: #selector(tap),
            for: .touchUpInside
        )
    }

    @objc
    private func tap() {
        action.handler?()
    }
}

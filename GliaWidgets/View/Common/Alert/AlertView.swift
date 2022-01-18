import UIKit
import PureLayout

final class AlertView: UIView {
    var dismiss: (() -> Void)?

    private let alertStyle: AlertStyle
    private let contentView = UIView()
    private let stackView = UIStackView()

    init(alertStyle: AlertStyle) {
        self.alertStyle = alertStyle

        super.init(frame: .zero)

        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .black.withAlphaComponent(0.25)

        contentView.backgroundColor = alertStyle.backgroundColor
        contentView.layer.cornerRadius = 24

        stackView.axis = .vertical
        stackView.spacing = 16
    }

    private func layout() {
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewSafeArea(with: .uniform(10), excludingEdge: .top)
        contentView.autoPinEdge(toSuperviewSafeArea: .top, withInset: 10, relation: .greaterThanOrEqual)

        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: .horizontal(32) + .vertical(24))
    }

    func configure(for showsCloseButton: Bool) {
        if showsCloseButton {
            let closeButton = Button(
                kind: .alertClose,
                tap: { [weak self] in self?.dismiss?() }
            )

            closeButton.tintColor = alertStyle.closeButtonColor
            addSubview(closeButton)
            closeButton.autoPinEdge(toSuperviewEdge: .right, withInset: 23)
            closeButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 24)
        }
    }

    func configure(for items: [AlertItem]) {
        items.forEach { item in
            let view = createView(for: item)

            if
                item.isActionsItem,
                let lastView = stackView.arrangedSubviews.last
            {
                stackView.setCustomSpacing(24, after: lastView)
            } else
                if case .poweredByGlia = item,
                let lastView = stackView.arrangedSubviews.last
            {
                stackView.setCustomSpacing(24, after: lastView)
            }

            stackView.addArrangedSubview(view)
        }
    }

    private func createView(for item: AlertItem) -> UIView {
        switch item {
        case let .title(text):
            return AlertTitleItemView(
                text: text,
                alertStyle: alertStyle
            )

        case let .message(text):
            return AlertMessageItemView(
                text: text,
                alertStyle: alertStyle
            )

        case let .illustration(image):
            return AlertIllustrationItemView(image: image)

        case let .actions(actions):
            return AlertActionsItemView(
                actions: actions,
                alertStyle: alertStyle
            )

        case .poweredByGlia:
            return PoweredByGliaView()
        }
    }
}

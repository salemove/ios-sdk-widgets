import UIKit
import PureLayout

final class AlertTitleItemView: UIView {
    private let label = UILabel()
    private let text: String
    private let alertStyle: AlertStyle

    init(
        text: String,
        alertStyle: AlertStyle
    ) {
        self.text = text
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
        label.numberOfLines = 0
        label.font = alertStyle.titleFont
        label.textColor = alertStyle.titleColor
        label.textAlignment = .center
        label.text = text
    }

    private func layout() {
        addSubview(label)
        label.autoPinEdgesToSuperviewEdges()
    }
}

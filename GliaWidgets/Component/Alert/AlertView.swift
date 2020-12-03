import UIKit

class AlertView: UIView {
    private let style: AlertStyle
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()
    private let buttonsStackView = UIStackView()
    private let kContentInsets = UIEdgeInsets(top: 28, left: 32, bottom: 28, right: 32)

    public init(with style: AlertStyle,
                title: String?,
                message: String?,
                buttons: [AlertButton]) {
        self.style = style
        super.init(frame: .zero)
        setup(title: title,
              message: message,
              buttons: buttons)
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(title: String?,
                       message: String?,
                       buttons: [AlertButton]) {
        backgroundColor = style.backgroundColor

        stackView.axis = .vertical
        stackView.spacing = 16

        titleLabel.numberOfLines = 0
        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor
        titleLabel.textAlignment = .center
        titleLabel.text = title

        messageLabel.numberOfLines = 0
        messageLabel.font = style.messageFont
        messageLabel.textColor = style.messageColor
        messageLabel.textAlignment = .center
        messageLabel.text = message

        buttonsStackView.spacing = 11
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.axis = buttons.count > 2
            ? .vertical
            : .horizontal
        buttonsStackView.addArrangedSubviews(buttons)
    }

    private func layout() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: kContentInsets)
    }
}

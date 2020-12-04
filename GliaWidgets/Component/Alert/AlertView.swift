import UIKit

class AlertView: UIView {
    private let style: AlertStyle
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()
    private let actionsStackView = UIStackView()
    private let kContentInsets = UIEdgeInsets(top: 28, left: 32, bottom: 28, right: 32)

    public init(with style: AlertStyle,
                title: String?,
                message: String?) {
        self.style = style
        super.init(frame: .zero)
        setup(title: title, message: message)
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addAction(_ action: AlertAction) {
        actionsStackView.addArrangedSubview(action)
        actionsStackView.axis = actionsStackView.arrangedSubviews.count > 2
            ? .vertical
            : .horizontal
    }

    private func setup(title: String?,
                       message: String?) {
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

        actionsStackView.spacing = 11
        actionsStackView.distribution = .fillEqually
    }

    private func layout() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: kContentInsets)
    }
}

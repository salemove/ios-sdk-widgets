import UIKit

class AlertView: UIView {
    enum ActionKind {
        case positive
        case negative
    }

    var closeTapped: (() -> Void)?

    private let style: AlertStyle
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()
    private let actionsStackView = UIStackView()
    private let kContentInsets = UIEdgeInsets(top: 28, left: 32, bottom: 28, right: 32)
    private let kCornerRadius: CGFloat = 30
    private var closeButton: Button?
    private var showsCloseButton: Bool = false {
        didSet {
            if showsCloseButton {
                let closeButton = Button(kind: .alertClose,
                                         tap: { [weak self] in self?.closeTapped?() })
                closeButton.tintColor = style.closeButtonColor
                self.closeButton = closeButton
                addSubview(closeButton)
                closeButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
                closeButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
            } else {
                closeButton?.removeFromSuperview()
            }
        }
    }
    private var actionCount: Int {
        return actionsStackView.arrangedSubviews.count
    }

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

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: kCornerRadius, height: kCornerRadius)
        ).cgPath
    }

    func addAction(title: String, kind: ActionKind, action: @escaping () -> Void) {
        let actionStyle = style(for: kind)
        let alertAction = AlertAction(with: actionStyle)
        alertAction.title = title
        alertAction.tap = { action() }

        actionsStackView.addArrangedSubview(alertAction)
        actionsStackView.axis = actionCount > 2
            ? .vertical
            : .horizontal
    }

    func show(animated: Bool) {
        showsCloseButton = actionCount == 0
    }

    func hide(animated: Bool) {

    }

    private func style(for kind: ActionKind) -> AlertActionStyle {
        switch kind {
        case .positive:
            return style.positiveAction
        case .negative:
            return style.negativeAction
        }
    }

    private func setup(title: String?,
                       message: String?) {
        backgroundColor = style.backgroundColor
        clipsToBounds = true

        layer.masksToBounds = false
        layer.cornerRadius = kCornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        layer.shadowRadius = 30.0
        layer.shadowOpacity = 0.2

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.addArrangedSubviews([
            titleLabel,
            messageLabel,
            actionsStackView
        ])

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

import UIKit

class AlertView: UIView {
    enum ActionKind {
        case positive
        case negative
    }

    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var message: String? {
        get { return messageLabel.text }
        set { messageLabel.text = newValue }
    }
    var showsCloseButton: Bool = false {
        didSet {
            if showsCloseButton {
                addCloseButton()
            } else {
                removeCloseButton()
            }
        }
    }
    var showsPoweredBy: Bool = false {
        didSet {
            if showsPoweredBy {
                addPoweredBy()
            } else {
                removePoweredBy()
            }
        }
    }
    var actionCount: Int {
        return actionsStackView.arrangedSubviews.count
    }
    var actionsAxis: NSLayoutConstraint.Axis {
        get { return actionsStackView.axis }
        set { actionsStackView.axis = newValue }
    }
    var closeTapped: (() -> Void)?

    private let style: AlertStyle
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()
    private let actionsStackView = UIStackView()
    private let kContentInsets = UIEdgeInsets(top: 28, left: 32, bottom: 28, right: 32)
    private let kCornerRadius: CGFloat = 30
    private var poweredBy: PoweredBy?
    private var closeButton: Button?

    public init(with style: AlertStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
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

    func addActionView(_ actionView: UIView) {
        actionsStackView.addArrangedSubview(actionView)
    }

    private func style(for kind: ActionKind) -> AlertActionButtonStyle {
        switch kind {
        case .positive:
            return style.positiveAction
        case .negative:
            return style.negativeAction
        }
    }

    private func setup() {
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

        messageLabel.numberOfLines = 0
        messageLabel.font = style.messageFont
        messageLabel.textColor = style.messageColor
        messageLabel.textAlignment = .center

        actionsStackView.spacing = 11
        actionsStackView.distribution = .fillEqually
    }

    private func layout() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: kContentInsets)
    }

    private func addCloseButton() {
        guard closeButton == nil else { return }

        let closeButton = Button(kind: .alertClose,
                                 tap: { [weak self] in self?.closeTapped?() })
        closeButton.tintColor = style.closeButtonColor
        self.closeButton = closeButton
        addSubview(closeButton)
        closeButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
        closeButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
    }

    private func removeCloseButton() {
        closeButton?.removeFromSuperview()
    }

    private func addPoweredBy() {
        guard poweredBy == nil else { return }

        let poweredBy = PoweredBy()
        self.poweredBy = poweredBy

        stackView.addArrangedSubview(poweredBy)
        stackView.setCustomSpacing(23, after: actionsStackView)
    }

    private func removePoweredBy() {
        poweredBy?.removeFromSuperview()
    }
}

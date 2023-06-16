import UIKit

class AlertView: BaseView {
    enum ActionKind {
        case positive
        case negative
    }

    var titleImage: UIImage? {
        get { return titleImageView.image }
        set {
            titleImageView.image = newValue

            if newValue == nil {
                titleImageView.removeFromSuperview()
            } else {
                guard titleImageView.superview == nil else { return }
                titleImageViewContainer.addSubview(titleImageView)
                titleImageView.translatesAutoresizingMaskIntoConstraints = false
                var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
                constraints += titleImageView.layoutInSuperview(edges: .vertical)
                constraints += titleImageView.layoutInCenter(titleImageViewContainer)
                constraints += titleImageView.leadingAnchor.constraint(greaterThanOrEqualTo: titleImageViewContainer.leadingAnchor)
                constraints += titleImageView.trailingAnchor.constraint(lessThanOrEqualTo: titleImageViewContainer.trailingAnchor)
            }
        }
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

    var closeTapped: (() -> Void)?

    private let style: AlertStyle
    private let titleImageView = UIImageView().makeView()
    private let titleImageViewContainer = UIView().makeView()
    private let titleLabel = UILabel().makeView()
    private let messageLabel = UILabel().makeView()
    private let stackView = UIStackView().makeView()
    private let actionsStackView = UIStackView().makeView()
    private let kContentInsets = UIEdgeInsets(top: 28, left: 32, bottom: 28, right: 32)
    private let kCornerRadius: CGFloat = 30
    private let titleImageViewSize: CGFloat = 32
    private var poweredBy: PoweredBy?
    private var closeButton: Button?

    init(with style: AlertStyle) {
        self.style = style
        super.init()
    }

    @available(*, unavailable)
    required init() {
        fatalError("init() has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()

        switch style.backgroundColor {
        case .fill(let color):
            backgroundColor = color
        case .gradient(let colors):
            makeGradientBackground(
                colors: colors,
                cornerRadius: kCornerRadius
            )
        }
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: kCornerRadius, height: kCornerRadius)
        ).cgPath
    }

    func addActionView(_ actionView: UIView) {
        actionsStackView.addArrangedSubview(actionView)
    }

    override func setup() {
        super.setup()
        clipsToBounds = true

        layer.masksToBounds = false
        layer.cornerRadius = kCornerRadius
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        layer.shadowRadius = 30.0
        layer.shadowOpacity = 1.0

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.addArrangedSubviews([
            titleImageViewContainer,
            titleLabel,
            messageLabel,
            actionsStackView
        ])

        titleImageView.contentMode = .scaleAspectFit
        titleImageView.tintColor = style.titleImageColor

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
        actionsStackView.axis = style.actionAxis

        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: titleLabel
        )
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: messageLabel
        )
    }

    override func defineLayout() {
        super.defineLayout()
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += stackView.layoutInSuperview(insets: kContentInsets)
        constraints += titleImageView.match(value: titleImageViewSize)
    }

    private func addCloseButton() {
        guard closeButton == nil else { return }

        let closeButton = Button(kind: .alertClose,
                                 tap: { [weak self] in self?.closeTapped?() })
        switch style.closeButtonColor {
        case .fill(let color):
            closeButton.tintColor = color
        case .gradient(let colors):
            closeButton.makeGradientBackground(colors: colors)
        }

        closeButton.accessibilityIdentifier = "alert_close_button"
        self.closeButton = closeButton
        addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        [
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ].activate()
    }

    private func removeCloseButton() {
        closeButton?.removeFromSuperview()
    }

    private func addPoweredBy() {
        guard poweredBy == nil else { return }

        let poweredBy = PoweredBy(style: style.poweredBy)
        self.poweredBy = poweredBy

        stackView.addArrangedSubview(poweredBy)
        stackView.setCustomSpacing(23, after: actionsStackView)
    }

    private func removePoweredBy() {
        poweredBy?.removeFromSuperview()
    }
}

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
            updateStackContents()
        }
    }
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue; updateStackContents() }
    }
    var message: String? {
        get { return messageLabel.text }
        set { messageLabel.text = newValue; updateStackContents() }
    }
    var showsCloseButton: Bool = false {
        didSet { updateStackContents() }
    }
    var showsPoweredBy: Bool = false {
        didSet { updateStackContents() }
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
    private let linkButtonStackView = UIStackView().makeView()
    private let actionsStackView = UIStackView().makeView()
    private let kContentInsets = UIEdgeInsets(top: 32, left: 32, bottom: 24, right: 32)
    private let kCornerRadius: CGFloat = 16
    private let titleImageViewSize: CGFloat = 32
    private var poweredBy: PoweredBy?
    private var closeButton: Button?
    private var closeButtonRow: UIStackView?

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

    func addLinkButton(_ contentView: UIView) {
        linkButtonStackView.isHidden = false
        linkButtonStackView.addArrangedSubview(contentView)
        updateStackContents()
    }

    func addActionView(_ actionView: UIView) {
        actionsStackView.addArrangedSubview(actionView)
        updateStackContents()
    }

    override func setup() {
        super.setup()
        clipsToBounds = true

        layer.masksToBounds = false
        layer.cornerRadius = kCornerRadius
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        layer.shadowRadius = 30.0
        layer.shadowOpacity = 1.0

        stackView.axis = .vertical
        stackView.spacing = 16

        titleImageView.contentMode = .scaleAspectFit
        titleImageView.tintColor = style.titleImageColor

        titleLabel.numberOfLines = 0
        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor
        titleLabel.textAlignment = style.titleAlignment

        messageLabel.numberOfLines = 0
        messageLabel.font = style.messageFont
        messageLabel.textColor = style.messageColor
        messageLabel.textAlignment = style.messageAlignment

        linkButtonStackView.isHidden = true
        linkButtonStackView.axis = .vertical
        linkButtonStackView.spacing = 8

        actionsStackView.spacing = 8
        actionsStackView.distribution = .fillEqually
        actionsStackView.axis = style.actionAxis
        actionsStackView.isLayoutMarginsRelativeArrangement = true
        actionsStackView.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

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
    
    private func makeCloseButtonRow() -> UIStackView {
        let closeRow = UIStackView()
        closeRow.axis = .horizontal
        closeRow.alignment = .fill
        closeRow.distribution = .fill
        closeRow.isLayoutMarginsRelativeArrangement = true
        closeRow.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let spacer = UIView()
        let closeButton = Button(
            kind: .alertClose,
            tap: { [weak self] in self?.closeTapped?() }
        )
        closeButton.accessibilityIdentifier = "alert_close_button"
        closeButton.setContentHuggingPriority(.required, for: .horizontal)
        closeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        switch style.closeButtonColor {
        case .fill(let color):
            closeButton.tintColor = color
        case .gradient(let colors):
            closeButton.makeGradientBackground(colors: colors)
        }

        closeRow.addArrangedSubview(spacer)
        closeRow.addArrangedSubview(closeButton)

        self.closeButton = closeButton
        self.closeButtonRow = closeRow

        return closeRow
    }

    private func getOrCreatePoweredBy() -> PoweredBy {
        if let poweredBy = poweredBy {
            return poweredBy
        } else {
            let newPoweredBy = PoweredBy(style: style.poweredBy)
            self.poweredBy = newPoweredBy
            return newPoweredBy
        }
    }

    private func updateStackContents() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let iconAndTitleStack = UIStackView()
        iconAndTitleStack.axis = .vertical
        iconAndTitleStack.alignment = .center
        iconAndTitleStack.spacing = 8

        if titleImageView.image != nil {
            if titleImageView.superview == nil {
                titleImageViewContainer.addSubview(titleImageView)
                titleImageView.translatesAutoresizingMaskIntoConstraints = false
                var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
                constraints += titleImageView.layoutInSuperview(edges: .vertical)
                constraints += titleImageView.layoutInCenter(titleImageViewContainer)
                constraints += titleImageView.leadingAnchor.constraint(greaterThanOrEqualTo: titleImageViewContainer.leadingAnchor)
                constraints += titleImageView.trailingAnchor.constraint(lessThanOrEqualTo: titleImageViewContainer.trailingAnchor)
            }
            iconAndTitleStack.addArrangedSubview(titleImageViewContainer)
            iconAndTitleStack.addArrangedSubview(titleLabel)
        } else {
            iconAndTitleStack.addArrangedSubview(titleLabel)
        }

        stackView.addArrangedSubview(iconAndTitleStack)
        if let message = messageLabel.text, !message.isEmpty {
            stackView.addArrangedSubview(messageLabel)
        }

        if !linkButtonStackView.isHidden && !linkButtonStackView.arrangedSubviews.isEmpty {
            stackView.addArrangedSubview(linkButtonStackView)
        }

        if !actionsStackView.arrangedSubviews.isEmpty {
            stackView.addArrangedSubview(actionsStackView)
        }

        if showsCloseButton {
            let closeRow = makeCloseButtonRow()
            stackView.addArrangedSubview(closeRow)
        }

        if showsPoweredBy {
            let pb = getOrCreatePoweredBy()
            stackView.addArrangedSubview(pb)
        }
    }
}

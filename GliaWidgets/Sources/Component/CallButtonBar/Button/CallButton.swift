import UIKit

class CallButton: UIView {
    enum Kind {
        case chat
        case video
        case mute
        case speaker
        case minimize
    }

    enum State {
        case active
        case inactive
    }

    var kind: Kind
    var state: State = .inactive {
        didSet { update(for: state) }
    }
    var isEnabled: Bool = true {
        didSet { setIsEnabled(isEnabled) }
    }
    var tap: (() -> Void)?

    private let style: CallButtonStyle
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let circleView = UIView()
    private var badgeView: BadgeView?
    private let circleSize: CGFloat = 60
    private let imageViewSize: CGFloat = 21

    init(kind: Kind, style: CallButtonStyle) {
        self.kind = kind
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setBadge(itemCount: Int, style: BadgeStyle) {
        if itemCount <= 0 {
            badgeView?.removeFromSuperview()
            badgeView = nil
        } else {
            if badgeView == nil {
                let badgeView = BadgeView(with: style)
                self.badgeView = badgeView
                addSubview(badgeView)
                badgeView.translatesAutoresizingMaskIntoConstraints = false
                var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
                constraints += badgeView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -badgeView.size / 2)
                constraints += badgeView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -badgeView.size / 2)
            }
        }
        badgeView?.newItemCount = itemCount
        updateAccessibilityProperties()
    }

    private func setup() {
        circleView.clipsToBounds = true
        circleView.layer.cornerRadius = circleSize / 2.0

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false
        imageView.accessibilityElementsHidden = true

        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: titleLabel
        )

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapped)
        )
        addGestureRecognizer(tapRecognizer)

        isAccessibilityElement = true
        accessibilityTraits = [.button]
        accessibilityElements = []

        update(for: state)
    }

    private func layout() {
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        addSubview(circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        constraints += circleView.match(value: circleSize)
        constraints += circleView.topAnchor.constraint(equalTo: topAnchor)
        constraints += circleView.centerXAnchor.constraint(equalTo: centerXAnchor)
        constraints += circleView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
        constraints += circleView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)

        circleView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        constraints += imageView.match(value: imageViewSize)
        constraints += imageView.layoutInCenter(circleView)

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints += titleLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 4)
        constraints += titleLabel.layoutInSuperview(edges: .horizontal)
        constraints += titleLabel.layoutInSuperview(edges: .bottom)
    }

    private func update(for state: State) {
        let style = self.style(for: state)
        switch style.backgroundColor {
        case .fill(let color):
            circleView.backgroundColor = color
        case .gradient(let colors):
            circleView.makeGradientBackground(
                colors: colors,
                cornerRadius: circleView.layer.cornerRadius
            )
        }
        imageView.image = style.image
        switch style.imageColor {
        case .fill(let color):
            imageView.tintColor = color
        case .gradient(let colors):
            imageView.makeGradientBackground(colors: colors)

        }
        titleLabel.text = style.title
        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor
        updateAccessibilityProperties()
    }

    private func setIsEnabled(_ isEnabled: Bool) {
        isUserInteractionEnabled = isEnabled
        alpha = isEnabled ? 1.0 : 0.4
        isAccessibilityElement = isEnabled
    }

    private func updateAccessibilityProperties() {
        let properties = Self.accessibility(
            for: kind,
            state: state,
            buttonStyle: style,
            stateStyle: style(for: state),
            badgeItemCount: badgeView?.newItemCount
        )
        accessibilityValue = properties.value
        accessibilityLabel = properties.label

        let buttonAccessibilityIdentifier = "media_\(properties.value.lowercased())_button"
        accessibilityIdentifier = isUserInteractionEnabled ? buttonAccessibilityIdentifier : ""
    }

    private func style(for state: State) -> CallButtonStyle.StateStyle {
        switch state {
        case .active:
            return style.active
        case .inactive:
            return style.inactive
        }
    }

    @objc private func tapped() {
        tap?()
    }

    static func accessibility(
        for kind: Kind,
        state: State,
        buttonStyle: CallButtonStyle,
        stateStyle: CallButtonStyle.StateStyle,
        badgeItemCount: Int?
    ) -> (label: String?, value: String) {

        let badgeValue: String

        switch badgeItemCount {
        case let .some(itemCount):
            badgeValue = (itemCount == 1 ? buttonStyle.accessibility.singleItemBadgeValue : buttonStyle.accessibility.multipleItemsBadgeValue)
                .withBadgeValue("\(itemCount)")
        case .none:
            badgeValue = ""
        }

        let value: String

        switch (stateStyle.title.isEmpty, badgeValue.isEmpty) {
        case (true, true):
            value = stateStyle.title
        case (false, false):
            value = buttonStyle.accessibility.titleAndBadgeValue
                .withButtonTitle(stateStyle.title)
                .withBadgeValue(badgeValue)
        case (false, true):
            value = stateStyle.title
        case (true, false):
            value = badgeValue
        }

        return (stateStyle.accessibility.label, value)
    }
}

import UIKit

/// Defines navigation header for engagement view.
/// This header has different states for `chat history` and `engaged`
/// states.
final class Header: BaseView {
    enum Effect: Equatable {
        case none
        case blur
    }

    var backButton: HeaderButton?
    var closeButton: HeaderButton?
    var endButton: ActionButton?
    var endScreenShareButton: HeaderButton?

    var props: Props {
        didSet {
            renderProps()
        }
    }
    private let leftItemContainer = UIView()
    private let rightItemContainer = UIStackView()
    private let titleLabel = UILabel()
    private let contentView = UIView()
    private var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var heightConstraint: NSLayoutConstraint?
    private let contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16)
    private let contentHeight: CGFloat = 30
    private let height: CGFloat = 58

    init(props: Props) {
        if let backButtonProps = props.backButton {
            self.backButton = HeaderButton(with: backButtonProps)
        }

        self.props = props
        if let closeButtonProps = props.closeButton {
            self.closeButton = HeaderButton(with: closeButtonProps)
        }
        if let endButtonProps = props.endButton {
            self.endButton = ActionButton(props: endButtonProps)
        }
        if let endScreenshareProps = props.endScreenshareButton {
            self.endScreenShareButton = HeaderButton(with: endScreenshareProps)
        }
        super.init()
        self.titleLabel.accessibilityTraits = .header
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeight()
        switch props.style.backgroundColor {
        case .fill(let color):
            backgroundColor = color
        case .gradient(let colors):
            makeGradientBackground(colors: colors)
        }
    }

    func renderProps() {
        backButton?.isHidden = props.backButton == nil
        if let backButtonProps = props.backButton {
            backButton?.props = backButtonProps
        }
        if let closeButtonProps = props.closeButton {
            closeButton?.props = closeButtonProps
        }
        if let endButtonProps = props.endButton {
            endButton?.props = endButtonProps
        }

        titleLabel.text = props.title
        titleLabel.accessibilityLabel = props.title
        titleLabel.accessibilityIdentifier = "header_view_title_label"

        effectView.isHidden = props.effect == .none
        titleLabel.font = props.style.titleFont
        titleLabel.textColor = props.style.titleColor

        closeButton?.accessibilityLabel = props.style.closeButton.accessibility.label
        endButton?.accessibilityLabel = props.style.endButton.accessibility.label
        setFontScalingEnabled(
            props.style.accessibility.isFontScalingEnabled,
            for: titleLabel
        )
    }

    func showBackButton() {
        backButton?.isHidden = false
    }

    func showCloseButton() {
        endButton?.isHidden = true
        endScreenShareButton?.isHidden = true
        closeButton?.isHidden = false
    }

    func showEndButton() {
        endButton?.isHidden = false
        closeButton?.isHidden = true
        endScreenShareButton?.isHidden = true
    }

    func showEndScreenSharingButton() {
        endButton?.isHidden = false
        endScreenShareButton?.isHidden = false
        closeButton?.isHidden = true
    }

    override func setup() {
        super.setup()
        titleLabel.textAlignment = .center
        rightItemContainer.axis = .horizontal
        rightItemContainer.spacing = 16
        rightItemContainer.alignment = .center
        backButton?.accessibilityIdentifier = "header_back_button"
        closeButton?.accessibilityIdentifier = "header_close_button"
    }

    override func defineLayout() {
        super.defineLayout()
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }

        heightConstraint = match(.height, value: height).first
        constraints += [heightConstraint].compactMap { $0 }

        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        constraints += effectView.layoutInSuperview()

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        constraints += contentView.layoutInSuperview(edges: .horizontal, insets: contentInsets)
        constraints += contentView.layoutInSuperview(edges: .bottom, insets: contentInsets)
        constraints += contentView.match(.height, value: contentHeight)

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints += titleLabel.layoutInSuperview(edges: .horizontal)
        constraints += titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        constraints += titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)

        if let backButton = backButton {
            contentView.addSubview(backButton)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            constraints += backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
            constraints += backButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        }

        if let endScreenShareButton {
            rightItemContainer.addArrangedSubview(endScreenShareButton)
        }
        if let endButton {
            rightItemContainer.addArrangedSubview(endButton)
        }
        if let closeButton {
            rightItemContainer.addArrangedSubview(closeButton)
        }
        contentView.addSubview(rightItemContainer)
        rightItemContainer.translatesAutoresizingMaskIntoConstraints = false
        constraints += rightItemContainer.layoutInSuperview(edges: .trailing)
        constraints += rightItemContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        updateHeight()

        renderProps()
    }

    private func updateHeight() {
        heightConstraint?.constant = height + safeAreaInsets.top
    }
}

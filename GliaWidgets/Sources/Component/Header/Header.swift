import UIKit
import PureLayout

/// Defines navigation header for engagement view.
/// This header has different states for `chat history` and `engaged`
/// states.
final class Header: BaseView {
    enum Effect: Equatable {
        case none
        case blur
    }

    var backButton: HeaderButton?
    var closeButton: HeaderButton
    var endButton: ActionButton
    var endScreenShareButton: HeaderButton

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
        self.closeButton = HeaderButton(with: props.closeButton)
        self.endButton = ActionButton(props: props.endButton)

        self.endScreenShareButton = HeaderButton(with: props.endScreenshareButton)
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

        closeButton.props = props.closeButton
        endButton.props = props.endButton

        titleLabel.text = props.title
        titleLabel.accessibilityLabel = props.title

        effectView.isHidden = props.effect == .none
        titleLabel.font = props.style.titleFont
        titleLabel.textColor = props.style.titleColor

        closeButton.accessibilityLabel = props.style.closeButton.accessibility.label
        endButton.accessibilityLabel = props.style.endButton.accessibility.label
        setFontScalingEnabled(
            props.style.accessibility.isFontScalingEnabled,
            for: titleLabel
        )
    }

    func showBackButton() {
        backButton?.isHidden = false
    }

    func showCloseButton() {
        endButton.isHidden = true
        endScreenShareButton.isHidden = true
        closeButton.isHidden = false
    }

    func showEndButton() {
        endButton.isHidden = false
        closeButton.isHidden = true
        endScreenShareButton.isHidden = true
    }

    func showEndScreenSharingButton() {
        endButton.isHidden = false
        endScreenShareButton.isHidden = false
        closeButton.isHidden = true
    }

    override func setup() {
        super.setup()
        titleLabel.textAlignment = .center
        rightItemContainer.axis = .horizontal
        rightItemContainer.spacing = 16
        rightItemContainer.alignment = .center
        backButton?.accessibilityIdentifier = "header_back_button"
        closeButton.accessibilityIdentifier = "header_close_button"
    }

    override func defineLayout() {
        super.defineLayout()
        heightConstraint = autoSetDimension(.height, toSize: height)

        addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: contentInsets, excludingEdge: .top)
        contentView.autoSetDimension(.height, toSize: contentHeight)

        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .left)
        titleLabel.autoPinEdge(toSuperviewEdge: .right)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

        if let backButton = backButton {
            contentView.addSubview(backButton)
            backButton.autoPinEdge(toSuperviewEdge: .left)
            backButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        }

        rightItemContainer.addArrangedSubviews([endScreenShareButton, endButton, closeButton])
        contentView.addSubview(rightItemContainer)
        rightItemContainer.autoPinEdge(toSuperviewEdge: .right)
        rightItemContainer.autoAlignAxis(toSuperviewAxis: .horizontal)

        updateHeight()

        renderProps()
    }

    private func updateHeight() {
        heightConstraint?.constant = height + safeAreaInsets.top
    }
}

import UIKit
import PureLayout

class Header: UIView {
    enum Effect {
        case none
        case blur
    }

    var title: String? {
        get { return titleLabel.text }
        set {
            titleLabel.text = newValue
            titleLabel.accessibilityLabel = newValue
        }
    }
    var effect: Effect = .none {
        didSet {
            switch effect {
            case .none:
                effectView.isHidden = true
            case .blur:
                effectView.isHidden = false
            }
        }
    }
    var backButton: HeaderButton
    var closeButton: HeaderButton
    var endButton: ActionButton
    var endScreenShareButton: HeaderButton

    private let style: HeaderStyle
    private let leftItemContainer = UIView()
    private let rightItemContainer = UIStackView()
    private let titleLabel = UILabel()
    private let contentView = UIView()
    private var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var heightConstraint: NSLayoutConstraint?
    private let kContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16)
    private let kContentHeight: CGFloat = 30
    private let kHeight: CGFloat = 58

    init(with style: HeaderStyle) {
        self.style = style
        self.backButton = HeaderButton(with: style.backButton)
        self.closeButton = HeaderButton(with: style.closeButton)
        self.endButton = ActionButton(with: style.endButton)
        self.endScreenShareButton = HeaderButton(with: style.endScreenShareButton)
        super.init(frame: .zero)
        self.titleLabel.accessibilityTraits = .header

        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeight()
    }

    func showBackButton() {
        backButton.isHidden = false
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

    private func setup() {
        effect = .none
        backgroundColor = style.backgroundColor

        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor
        titleLabel.textAlignment = .center

        rightItemContainer.axis = .horizontal
        rightItemContainer.spacing = 8
        rightItemContainer.alignment = .center

        backButton.accessibilityIdentifier = "header_back_button"
        closeButton.accessibilityIdentifier = "header_close_button"
        closeButton.accessibilityLabel = style.closeButton.accessibility.label
        endButton.accessibilityIdentifier = "header_end_button"
        endButton.accessibilityLabel = style.endButton.accessibility.label
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: titleLabel
        )
    }

    private func layout() {
        heightConstraint = autoSetDimension(.height, toSize: kHeight)

        addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets, excludingEdge: .top)
        contentView.autoSetDimension(.height, toSize: kContentHeight)

        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .left)
        titleLabel.autoPinEdge(toSuperviewEdge: .right)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

        contentView.addSubview(backButton)
        backButton.autoPinEdge(toSuperviewEdge: .left)
        backButton.autoAlignAxis(toSuperviewAxis: .horizontal)

        rightItemContainer.addArrangedSubviews([endScreenShareButton, endButton, closeButton])
        contentView.addSubview(rightItemContainer)
        rightItemContainer.autoPinEdge(toSuperviewEdge: .right)
        rightItemContainer.autoAlignAxis(toSuperviewAxis: .horizontal)

        updateHeight()
    }

    private func updateHeight() {
        heightConstraint?.constant = kHeight + safeAreaInsets.top
    }
}

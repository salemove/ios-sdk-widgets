import UIKit

class CallButtonBar: BaseView {
    enum Effect {
        case none
        case blur
    }

    var visibleButtons: [CallButton.Kind] = [] {
        didSet { showButtons(visibleButtons) }
    }
    var buttonTapped: ((CallButton.Kind) -> Void)?
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

    private let style: CallButtonBarStyle
    private let stackView = UIStackView()
    private var buttons = [CallButton]()
    private var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var bottomSpaceConstraint: NSLayoutConstraint?
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var verticalAlignConstrait: NSLayoutConstraint?
    private var kInsets = UIEdgeInsets(top: 7.0, left: 3.0, bottom: 7.0, right: 3.0)

    init(with style: CallButtonBarStyle) {
        self.style = style
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        adjustBottomSpacing()
        adjustStackConstraints()
    }

    func adjustStackConstraints() {
        if currentOrientation.isPortrait {
            verticalAlignConstrait?.autoRemove()
            stackView.spacing = 2
            leftConstraint?.autoInstall()
            rightConstraint?.autoInstall()
        } else {
            leftConstraint?.autoRemove()
            rightConstraint?.autoRemove()
            stackView.spacing = 12
            verticalAlignConstrait?.autoInstall()
        }
    }

    func setButton(_ kind: CallButton.Kind, enabled: Bool) {
        button(for: kind)?.isEnabled = enabled
    }

    func setButton(_ kind: CallButton.Kind, state: CallButton.State) {
        button(for: kind)?.state = state
    }

    func setButton(_ kind: CallButton.Kind, badgeItemCount: Int) {
        button(for: kind)?.setBadge(itemCount: badgeItemCount, style: style.badge)
    }

    override func setup() {
        super.setup()
        effect = .none

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
    }

    override func defineLayout() {
        super.defineLayout()
        adjustStackConstraints()
        addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

        addSubview(stackView)
        stackView.autoPinEdge(toSuperviewEdge: .top, withInset: kInsets.top)
        leftConstraint = stackView.autoPinEdge(toSuperviewEdge: .left, withInset: kInsets.left)
        rightConstraint = stackView.autoPinEdge(toSuperviewEdge: .right, withInset: kInsets.right)
        verticalAlignConstrait = stackView.autoAlignAxis(toSuperviewAxis: .vertical)
        bottomSpaceConstraint = stackView.autoPinEdge(toSuperviewEdge: .bottom)
    }

    private func showButtons(_ buttonKinds: [CallButton.Kind]) {
        stackView.removeArrangedSubviews()
        buttons = buttonKinds.map { kind in
            let button = makeButton(for: kind)
            button.tap = { [weak self] in self?.buttonTapped?(kind) }
            return button
        }
        buttons.forEach {
            let wrapper = wrap($0)
            stackView.addArrangedSubview(wrapper)
        }
    }

    private func makeButton(for kind: CallButton.Kind) -> CallButton {
        switch kind {
        case .chat:
            return CallButton(
                kind: kind,
                style: CallButtonStyle(
                    active: style.chatButton.active,
                    inactive: style.chatButton.inactive,
                    selected: style.chatButton.selected,
                    accessibility: style.chatButton.accessibility
                )
            )
        case .video:
            return CallButton(
                kind: kind,
                style: CallButtonStyle(
                    active: style.videoButton.active,
                    inactive: style.videoButton.inactive,
                    selected: style.videoButton.selected,
                    accessibility: style.videoButton.accessibility
                )
            )
        case .mute:
            return CallButton(
                kind: kind,
                style: CallButtonStyle(
                    active: style.muteButton.active,
                    inactive: style.muteButton.inactive,
                    selected: style.muteButton.selected,
                    accessibility: style.muteButton.accessibility
                )
            )
        case .speaker:
            return CallButton(
                kind: kind,
                style: CallButtonStyle(
                    active: style.speakerButton.active,
                    inactive: style.speakerButton.inactive,
                    selected: style.speakerButton.selected,
                    accessibility: style.speakerButton.accessibility
                )
            )
        case .minimize:
            return CallButton(
                kind: kind,
                style: CallButtonStyle(
                    active: style.minimizeButton.active,
                    inactive: style.minimizeButton.inactive,
                    selected: style.minimizeButton.selected,
                    accessibility: style.minimizeButton.accessibility
                )
            )
        }
    }

    private func wrap(_ button: CallButton) -> UIView {
        let wrapper = UIView()
        wrapper.addSubview(button)
        button.autoPinEdge(toSuperviewEdge: .top)
        button.autoPinEdge(toSuperviewEdge: .bottom)
        button.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        button.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        button.autoAlignAxis(toSuperviewAxis: .vertical)
        return wrapper
    }

    private func button(for kind: CallButton.Kind) -> CallButton? {
        return buttons.first(where: { $0.kind == kind })
    }

    private func adjustBottomSpacing() {
        bottomSpaceConstraint?.constant = -(safeAreaInsets.bottom + kInsets.bottom)
    }
}

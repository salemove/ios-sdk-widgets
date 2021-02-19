import UIKit

class CallButtonBar: UIView {
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
    private var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    private var bottomSpaceConstraint: NSLayoutConstraint!
    private var kInsets = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)

    init(with style: CallButtonBarStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        adjustBottomSpacing()
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

    private func setup() {
        effect = .none

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
    }

    private func layout() {
        addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: kInsets, excludingEdge: .bottom)
        bottomSpaceConstraint = stackView.autoPinEdge(toSuperviewEdge: .bottom)
    }

    private func showButtons(_ buttonKinds: [CallButton.Kind]) {
        stackView.removeArrangedSubviews()
        buttons = buttonKinds.map({ kind in
            let button = makeButton(for: kind)
            button.tap = { [weak self] in self?.buttonTapped?(kind) }
            return button
        })
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
                    inactive: style.chatButton.inactive
                )
            )
        case .video:
            return CallButton(
                kind: kind,
                style: CallButtonStyle(
                    active: style.videoButton.active,
                    inactive: style.videoButton.inactive
                )
            )
        case .mute:
            return CallButton(
                kind: kind,
                style: CallButtonStyle(
                    active: style.muteButton.active,
                    inactive: style.muteButton.inactive
                )
            )
        case .speaker:
            return CallButton(
                kind: kind,
                style: CallButtonStyle(
                    active: style.speakerButton.active,
                    inactive: style.speakerButton.inactive
                )
            )
        case .minimize:
            return CallButton(
                kind: kind,
                style: CallButtonStyle(
                    active: style.minimizeButton.active,
                    inactive: style.minimizeButton.inactive
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
        bottomSpaceConstraint.constant = -(safeAreaInsets.bottom + kInsets.bottom)
    }
}

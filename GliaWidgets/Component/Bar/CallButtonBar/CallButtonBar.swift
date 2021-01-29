import UIKit

class CallButtonBar: UIView {
    var visibleButtons: [CallButton.Kind] = [] {
        didSet { showButtons(visibleButtons) }
    }
    var tap: ((Button) -> Void)?

    private let style: CallButtonBarStyle
    private let stackView = UIStackView()

    init(with style: CallButtonBarStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
    }

    private func layout() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }

    private func showButtons(_ buttonKinds: [CallButton.Kind]) {
        stackView.removeArrangedSubviews()
        buttonKinds.forEach {
            let button = makeButton(for: $0)
            let wrapper = wrap(button)
            stackView.addArrangedSubview(wrapper)
        }
    }

    private func makeButton(for kind: CallButton.Kind) -> CallButton {
        switch kind {
        case .chat:
            return CallButton(kind: kind,
                              style: CallButtonStyle(active: style.chatButton.active,
                                                     inactive: style.chatButton.inactive))
        case .video:
            return CallButton(kind: kind,
                              style: CallButtonStyle(active: style.videoButton.active,
                                                     inactive: style.videoButton.inactive))
        case .mute:
            return CallButton(kind: kind,
                              style: CallButtonStyle(active: style.muteButton.active,
                                                     inactive: style.muteButton.inactive))
        case .speaker:
            return CallButton(kind: kind,
                              style: CallButtonStyle(active: style.speakerButton.active,
                                                     inactive: style.speakerButton.inactive))
        case .minimize:
            return CallButton(kind: kind,
                              style: CallButtonStyle(active: style.minimizeButton.active,
                                                     inactive: style.minimizeButton.inactive))
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
}

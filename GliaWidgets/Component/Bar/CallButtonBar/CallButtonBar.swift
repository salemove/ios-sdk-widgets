import UIKit

class CallButtonBar: UIView {
    enum Button {
        case chat
        case video
        case mute
        case speaker
        case minimize
    }

    var visibleButtons: [Button] = [] {
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

    private func setup() {}

    private func layout() {

    }

    private func showButtons(_ buttons: [Button]) {
        stackView.removeArrangedSubviews()
        
    }
}

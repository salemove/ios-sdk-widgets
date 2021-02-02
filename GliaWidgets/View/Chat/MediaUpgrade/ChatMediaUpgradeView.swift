import UIKit

class ChatMediaUpgradeView: UIView {
    private let style: ChatMediaUpgradeStyle

    init(with style: ChatMediaUpgradeStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        
    }

    private func layout() {

    }
}

import UIKit

final class OverlayView: UIView {
    init(
        color: UIColor = UIColor.black.withAlphaComponent(0.4),
        isHidden: Bool = true,
        alpha: CGFloat = 0
    ) {
        super.init(frame: .zero)
        self.backgroundColor = color
        self.isHidden = isHidden
        self.alpha = alpha
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        isHidden = false
        isUserInteractionEnabled = true
    }

    func hide() {
        isHidden = true
        isUserInteractionEnabled = false
    }
}

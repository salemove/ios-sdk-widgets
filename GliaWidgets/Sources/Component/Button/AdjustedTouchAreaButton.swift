import UIKit

class AdjustedTouchAreaButton: UIButton {
    private var touchAreaInsets: TouchAreaInsets?

    init(touchAreaInsets: TouchAreaInsets? = nil) {
        super.init(frame: .zero)
        self.touchAreaInsets = touchAreaInsets
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let insets = touchAreaInsets else {
            return super.point(inside: point, with: event)
        }

        let area = bounds.insetBy(dx: insets.dx, dy: insets.dy)

        return area.contains(point)
    }
}

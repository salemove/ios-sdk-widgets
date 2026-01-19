import SwiftUI

final class OnHoldOverlayHost: UIView {
    private let hostingController: UIHostingController<OnHoldOverlay>

    init(style: OnHoldOverlayStyle) {
        hostingController = UIHostingController(rootView: OnHoldOverlay(style: style))
        super.init(frame: .zero)

        backgroundColor = .clear
        isUserInteractionEnabled = false

        let view = hostingController.view!
        view.backgroundColor = .clear
        view.isOpaque = false
        view.isUserInteractionEnabled = false

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(view.layoutInSuperview())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

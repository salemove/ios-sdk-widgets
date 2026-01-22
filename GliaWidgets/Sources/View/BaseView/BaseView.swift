import UIKit

class BaseView: UIView {
    var currentOrientation: UIInterfaceOrientation {
        let windowScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }

        return windowScene?.interfaceOrientation ?? .portrait
    }

    required init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Setup view and add all necessary subviews.
    func setup() {}

    /// Defines layout specific and establishes constraints.
    func defineLayout() {}

    override func updateConstraints() {
        if defineLayoutIsNeeded {
            defineLayoutIsNeeded = false
            defineLayout()
        }
        super.updateConstraints()
    }

    // MARK: - Private

    private var defineLayoutIsNeeded = true
}

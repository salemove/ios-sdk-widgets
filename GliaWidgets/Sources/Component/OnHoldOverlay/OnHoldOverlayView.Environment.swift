import Foundation

extension OnHoldOverlayView {
    struct Environment {
        let gcd: GCD
    }
}

extension OnHoldOverlayView.Environment {
    static func create(with environment: ConnectOperatorView.Environment) -> Self {
        .init(gcd: environment.gcd)
    }

    static func create(with environment: BubbleView.Environment) -> Self {
        .init(gcd: environment.gcd)
    }
}

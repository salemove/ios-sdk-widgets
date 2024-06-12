import Foundation

extension OnHoldOverlayVisualEffectView {
    struct Environment {
        let gcd: GCD
    }
}

extension OnHoldOverlayVisualEffectView.Environment {
    static func create(with environment: OnHoldOverlayView.Environment) -> Self {
        .init(gcd: environment.gcd)
    }
}

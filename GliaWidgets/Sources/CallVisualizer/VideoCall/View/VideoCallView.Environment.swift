import Foundation

extension CallVisualizer.VideoCallView {
    struct Environment {
        let gcd: GCD
        let uiScreen: UIKitBased.UIScreen
    }
}

extension CallVisualizer.VideoCallView.Environment {
    static func create(with environment: CallVisualizer.VideoCallCoordinator.Environment) -> Self {
        .init(
            gcd: environment.gcd,
            uiScreen: environment.uiScreen
        )
    }
}

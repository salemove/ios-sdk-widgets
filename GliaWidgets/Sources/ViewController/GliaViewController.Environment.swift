import Foundation
import GliaCoreSDK

extension GliaViewController {
    struct Environment {
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var log: CoreSdkClient.Logger
        var animate: (
            _ animated: Bool,
            _ animations: @escaping () -> Void,
            _ completion: @escaping (Bool) -> Void
        ) -> Void
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry

        func withAnimation(
            animated: Bool,
            animations: @escaping () -> Void,
            completion: @escaping (Bool) -> Void
        ) {
            animate(animated, animations, completion)
        }
    }
}

extension GliaViewController.Environment {
    static func create(
        with environment: EngagementCoordinator.Environment,
        animate: @escaping (
            _ animated: Bool,
            _ animations: @escaping () -> Void,
            _ completion: @escaping (
                Bool
            ) -> Void
        ) -> Void
    ) -> Self {
        .init(
            uiApplication: environment.uiApplication,
            uiScreen: environment.uiScreen,
            log: environment.log,
            animate: animate
        )
    }
}

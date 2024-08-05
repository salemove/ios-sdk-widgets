import Foundation

extension SecureConversations.WelcomeViewController {
    struct Environemnt {
        let gcd: GCD
        let uiScreen: UIKitBased.UIScreen
        let notificationCenter: FoundationBased.NotificationCenter
        var log: CoreSdkClient.Logger
    }
}

extension SecureConversations.WelcomeViewController.Environemnt {
    static func create(with environment: SecureConversations.Coordinator.Environment) -> Self {
        .init(
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            notificationCenter: environment.notificationCenter,
            log: environment.log
        )
    }
}

#if DEBUG
extension SecureConversations.WelcomeViewController.Environemnt {
    static func mock(
        gcd: GCD = .mock,
        uiScreen: UIKitBased.UIScreen = .mock,
        notificationCenter: FoundationBased.NotificationCenter = .mock,
        log: CoreSdkClient.Logger = .mock
    ) -> Self {
        .init(
            gcd: gcd,
            uiScreen: uiScreen,
            notificationCenter: notificationCenter,
            log: log
        )
    }
}
#endif

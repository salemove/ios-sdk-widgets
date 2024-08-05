import Foundation

extension SecureConversations.WelcomeView {
    struct Environemnt {
        let gcd: GCD
        let uiScreen: UIKitBased.UIScreen
        let notificationCenter: FoundationBased.NotificationCenter
    }
}

extension SecureConversations.WelcomeView.Environemnt {
    static func create(with environment: SecureConversations.WelcomeViewController.Environemnt) -> Self {
        .init(
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            notificationCenter: environment.notificationCenter
        )
    }
}

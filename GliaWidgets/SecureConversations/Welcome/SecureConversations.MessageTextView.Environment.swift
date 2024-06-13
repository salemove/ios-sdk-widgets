import Foundation

extension SecureConversations.WelcomeView.MessageTextView {
    struct Environemnt {
        let gcd: GCD
    }
}

extension SecureConversations.WelcomeView.MessageTextView.Environemnt {
    static func create(with environment: SecureConversations.WelcomeView.Environemnt) -> Self {
        .init(gcd: environment.gcd)
    }
}

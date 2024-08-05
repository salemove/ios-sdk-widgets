import Foundation

extension ChatMessageEntryView {
    struct Environment {
        var gcd: GCD
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
    }
}

extension ChatMessageEntryView.Environment {
    static func create(with environment: ChatView.Environment) -> Self {
        .init(
            gcd: environment.gcd,
            uiApplication: environment.uiApplication,
            uiScreen: environment.uiScreen
        )
    }
}

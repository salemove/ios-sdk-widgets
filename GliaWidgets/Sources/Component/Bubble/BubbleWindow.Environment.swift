import Foundation

extension BubbleWindow {
    struct Environment {
        var uiScreen: UIKitBased.UIScreen
        var uiApplication: UIKitBased.UIApplication
    }
}

extension BubbleWindow.Environment {
    static func create(with environment: GliaViewController.Environment) -> Self {
        .init(
            uiScreen: environment.uiScreen,
            uiApplication: environment.uiApplication
        )
    }
}

#if DEBUG
extension BubbleWindow.Environment {
    static let mock = Self(uiScreen: .mock, uiApplication: .mock)
}

#endif

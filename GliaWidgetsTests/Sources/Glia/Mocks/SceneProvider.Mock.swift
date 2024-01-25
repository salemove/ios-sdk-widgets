import UIKit
@testable import GliaWidgets

class MockedSceneProvider: SceneProvider {
    private let window = UIWindow()

    init () {}

    func windowScene() -> UIWindowScene? {
        window.windowScene
    }
}

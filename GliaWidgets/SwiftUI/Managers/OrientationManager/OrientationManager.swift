import SwiftUI
import Combine

final class OrientationManager: ObservableObject {
    @Published private(set) var orientation: UIInterfaceOrientation

    private let environment: Environment
    private var orientationSubscription: AnyCancellable?
    private var currentOrientation: UIInterfaceOrientation {
        environment.uiApplication.windows().first?.windowScene?.interfaceOrientation ?? .portrait
    }

    var isPortrait: Bool {
        orientation == .portrait || orientation == .portraitUpsideDown
    }

    var isLandscape: Bool {
        !isPortrait
    }

    init(environment: Environment) {
        self.environment = environment
        orientation = environment.uiApplication.windows().first?.windowScene?.interfaceOrientation ?? .portrait
        orientationSubscription = environment.notificationCenter
            .publisherForNotification(environment.uiDevice.orientationDidChangeNotification())
            .map { _ in self.currentOrientation }
            .removeDuplicates()
            .assign(to: \.orientation, on: self)
    }
}

extension OrientationManager {
    struct Environment {
        var uiApplication: UIKitBased.UIApplication
        var uiDevice: UIKitBased.UIDevice
        var notificationCenter: FoundationBased.NotificationCenter
    }
}

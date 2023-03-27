import UIKit

class ProximityManager {
    private var userDefaultScreenBrightness: CGFloat
    private let environment: Environment
    private let view: UIView

    init(
        view: UIView,
        environment: Environment
    ) {
        self.view = view
        self.environment = environment
        self.userDefaultScreenBrightness = environment.uiScreen.brightness()
    }

    func start() {
        environment.uiApplication.isIdleTimerDisabled(true)
        environment.uiDevice.isProximityMonitoringEnabled(true)
        environment.notificationCenter.addObserver(
            self,
            selector: #selector(proximityStateDidChange),
            name: UIDevice.proximityStateDidChangeNotification,
            object: nil
        )
    }

    func stop() {
        environment.notificationCenter.removeObserver(
            self,
            name: UIDevice.proximityStateDidChangeNotification,
            object: nil
        )
        environment.uiApplication.isIdleTimerDisabled(false)
        view.isUserInteractionEnabled = true
    }
}

private extension ProximityManager {
    @objc func proximityStateDidChange() {
        if environment.uiDevice.proximityState() {
            environment.uiScreen.setBrightness(0.0)
            view.isUserInteractionEnabled = false
        } else {
            environment.uiScreen.setBrightness(userDefaultScreenBrightness)
            view.isUserInteractionEnabled = true
        }
    }
}

extension ProximityManager {
    struct Environment {
        var uiApplication: UIKitBased.UIApplication
        var uiDevice: UIKitBased.UIDevice
        var uiScreen: UIKitBased.UIScreen
        var notificationCenter: FoundationBased.NotificationCenter
    }
}

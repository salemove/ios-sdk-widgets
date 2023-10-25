import UIKit

final class ProximityManager {
    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func start() {
        environment.uiApplication.isIdleTimerDisabled(true)
        environment.uiDevice.isProximityMonitoringEnabled(true)
    }

    func stop() {
        environment.uiApplication.isIdleTimerDisabled(false)
        environment.uiDevice.isProximityMonitoringEnabled(false)
    }
}

extension ProximityManager {
    struct Environment {
        var uiApplication: UIKitBased.UIApplication
        var uiDevice: UIKitBased.UIDevice
    }
}

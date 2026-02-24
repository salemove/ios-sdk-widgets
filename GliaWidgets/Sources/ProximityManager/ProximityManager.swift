import UIKit

final class ProximityManager {
    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func start() {
        let enableIdleTimerDisabled = environment.uiApplication.isIdleTimerDisabled
        let enableProximityMonitoring = environment.uiDevice.isProximityMonitoringEnabled
        environment.gcd.mainQueue.asyncIfNeeded {
            enableIdleTimerDisabled(true)
            enableProximityMonitoring(true)
        }
    }

    func stop() {
        let disableIdleTimer = environment.uiApplication.isIdleTimerDisabled
        let disableProximityMonitoring = environment.uiDevice.isProximityMonitoringEnabled
        environment.gcd.mainQueue.asyncIfNeeded {
            disableIdleTimer(false)
            disableProximityMonitoring(false)
        }
    }
}

extension ProximityManager {
    struct Environment {
        var uiApplication: UIKitBased.UIApplication
        var uiDevice: UIKitBased.UIDevice
        var gcd: GCD
    }
}

import Foundation
import UIKit

class CallDurationCounter {
    var isActive: Bool { timer != nil }

    private var onUpdate: ((Int) -> Void)?
    private var timer: FoundationBased.Timer?
    private var startTime: TimeInterval?
    private var environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func start(onUpdate: @escaping (Int) -> Void) {
        self.onUpdate = onUpdate

        startTime = Date().timeIntervalSince1970
        timer = environment.timerProviding.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(update),
            userInfo: nil,
            repeats: true
        )
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        startTime = nil
    }

    @objc
    private func update() {
        guard
            let startTime = startTime
        else { return }

        let currentTime = Date().timeIntervalSince1970
        let duration = Int(currentTime - startTime)

        onUpdate?(duration)
    }
}

extension CallDurationCounter {
    struct Environment {
        var timerProviding: FoundationBased.Timer.Providing
    }
}

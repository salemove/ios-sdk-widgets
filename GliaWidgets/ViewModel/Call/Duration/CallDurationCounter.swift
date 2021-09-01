import UIKit

class CallDurationCounter {
    var isActive: Bool { timer != nil }

    private var onUpdate: ((Int) -> Void)?
    private var timer: Timer?
    private var startTime: TimeInterval?

    func start(onUpdate: @escaping (Int) -> Void) {
        self.onUpdate = onUpdate
        
        startTime = Date().timeIntervalSince1970
        timer = Timer.scheduledTimer(
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

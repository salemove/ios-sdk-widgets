import UIKit

class CallDurationCounter {
    var isActive: Bool { return timer != nil }

    private var onUpdate: ((Int) -> Void)?
    private var timer: Timer?
    private var backgroundedTime: Date?
    private var duration = 0 {
        didSet { onUpdate?(duration) }
    }

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start(onUpdate: @escaping (Int) -> Void) {
        self.onUpdate = onUpdate
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func startTimer() {
        guard !isActive else { return }

        duration = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(update),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc private func update() {
        duration += 1
    }

    @objc private func didEnterBackground() {
        backgroundedTime = Date()
        stop()
    }

    @objc private func willEnterForeground() {
        guard let backgroundedTime = backgroundedTime else { return }
        let backgroundTime = Int( Date().timeIntervalSince(backgroundedTime) )
        duration += backgroundTime
        startTimer()
    }
}

import SwiftUI

struct ConnectPulseRings: View {
    let color: UIColor
    var size: CGFloat = 116
    private let epoch = Date().timeIntervalSinceReferenceDate
    private let duration: Double = 2.5
    private let instanceDelay: Double = 0.3
    private let instanceCount: Int = 2

    var body: some View {
        TimelineView(.animation) { context in
            let now = context.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<instanceCount, id: \.self) { index in
                    let delay = Double(index) * instanceDelay
                    let progress = progress(now: now, delay: delay)

                    Circle()
                        .fill(SwiftUI.Color(color))
                        .width(size)
                        .height(size)
                        .scaleEffect(progress)
                        .opacity(opacity(for: progress))
                }
            }
            .frame(width: size, height: size)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    private func progress(
        now: TimeInterval,
        delay: TimeInterval
    ) -> CGFloat {
        let time = now - epoch - delay
        guard time >= 0 else { return 0 }
        let x = time.truncatingRemainder(dividingBy: duration)
        return CGFloat(x / duration)
    }

    private func opacity(for progress: CGFloat) -> Double {
        let p = max(0, min(1, progress))
        if p <= 0.5 {
            let local = p / 0.5
            return Double(0.5 + (0.8 - 0.5) * local)
        } else {
            let local = (p - 0.5) / 0.5
            return Double(0.8 + (0.0 - 0.8) * local)
        }
    }
}

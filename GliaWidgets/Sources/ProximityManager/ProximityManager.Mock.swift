#if DEBUG
import Foundation

extension ProximityManager {
    static let mock: ProximityManager = .init(
        environment: .init(
            uiApplication: .mock,
            uiDevice: .mock,
            gcd: .mock
        )
    )
}
#endif

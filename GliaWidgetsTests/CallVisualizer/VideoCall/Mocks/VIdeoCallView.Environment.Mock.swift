#if DEBUG

import Foundation

extension CallVisualizer.VideoCallView.Environment {
    static let mock = Self(gcd: .mock, uiScreen: .mock)
}

#endif

#if DEBUG

import Foundation

extension CallVisualizer.VideoCallViewModel {
    static func mock(
        style: CallStyle = Theme().callStyle,
        environment: CallVisualizer.VideoCallViewModel.Environment = .mock,
        call: Call = .mock()
    ) -> CallVisualizer.VideoCallViewModel {
        return .init(style: style, environment: environment, call: call)
    }
}

#endif

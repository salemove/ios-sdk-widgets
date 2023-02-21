#if DEBUG

import UIKit

extension CallVisualizer.VideoCallView.Props {
    static let mock = Self(
        style: .mock(),
        callDuration: "",
        connectViewProps: .mock,
        buttonBarProps: .mock(),
        headerTitle: "",
        operatorName: "",
        remoteVideoStream: .none,
        localVideoStream: .none,
        topLabelHidden: false,
        endScreenShareButtonHidden: false,
        connectViewHidden: false,
        topStackAlpha: 1.0,
        headerProps: .mock()
    )
}

#endif

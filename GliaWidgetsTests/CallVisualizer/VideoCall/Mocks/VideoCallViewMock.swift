#if DEBUG

import UIKit

extension CallVisualizer.VideoCallView.Props {
    static func mock(
        style: CallStyle = .mock(),
        callDuration: String? = "",
        connectViewProps: CallVisualizer.VideoCallView.ConnectView.Props = .mock,
        buttonBarProps: CallVisualizer.VideoCallView.CallButtonBar.Props = .mock(),
        headerTitle: String = "",
        operatorName: String? = "",
        remoteVideoStream: CoreSdkClient.StreamView? = .none,
        localVideoStream: CoreSdkClient.StreamView? = .none,
        topLabelHidden: Bool = false,
        endScreenShareButtonHidden: Bool = false,
        connectViewHidden: Bool = false,
        topStackAlpha: CGFloat = 1.0,
        headerProps: Header.Props = .mock()
    ) -> CallVisualizer.VideoCallView.Props {
        return .init(
            style: style,
            callDuration: callDuration,
            connectViewProps: connectViewProps,
            buttonBarProps: buttonBarProps,
            headerTitle: headerTitle,
            operatorName: operatorName,
            remoteVideoStream: remoteVideoStream,
            localVideoStream: localVideoStream,
            topLabelHidden: topLabelHidden,
            endScreenShareButtonHidden: endScreenShareButtonHidden,
            connectViewHidden: connectViewHidden,
            topStackAlpha: topStackAlpha,
            headerProps: headerProps
        )
    }
}

#endif

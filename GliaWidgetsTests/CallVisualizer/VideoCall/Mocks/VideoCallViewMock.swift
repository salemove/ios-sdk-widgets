#if DEBUG

import UIKit

extension CallVisualizer.VideoCallView.Props {
    static func mock(
        style: CallStyle = .mock(),
        callDuration: String? = "",
        connectState: EngagementState = .initial,
        buttonBarProps: CallVisualizer.VideoCallView.CallButtonBar.Props = .mock(),
        remoteVideoStream: CoreSdkClient.StreamView? = .none,
        localVideoStream: CoreSdkClient.StreamView? = .none,
        topLabelHidden: Bool = false,
        headerProps: Header.Props = .mock(),
        flipCameraTap: Cmd? = nil,
        flipCameraPropsAccessibility: FlipCameraButton.Props.Accessibility = .nop
    ) -> CallVisualizer.VideoCallView.Props {
        return .init(
            style: style,
            callDuration: callDuration,
            connectState: connectState,
            buttonBarProps: buttonBarProps,
            remoteVideoStream: remoteVideoStream,
            localVideoStream: localVideoStream,
            topLabelHidden: topLabelHidden,
            headerProps: headerProps,
            flipCameraTap: flipCameraTap,
            flipCameraPropsAccessibility: flipCameraPropsAccessibility
        )
    }
}

#endif

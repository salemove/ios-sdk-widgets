#if DEBUG

extension CallVisualizer.VideoCallView.CallButtonBar.Props {
    static func mock(
        style: CallButtonBarStyle = .mock(),
        videoButtonTap: Cmd = .nop,
        minimizeTap: Cmd = .nop,
        videoButtonState: CallButton.State = .active,
        videoButtonEnabled: Bool = true,
        minimizeButtonEnabled: Bool = true
    ) -> CallVisualizer.VideoCallView.CallButtonBar.Props {
        .init(
            style: style,
            videoButtonTap: videoButtonTap,
            minimizeTap: minimizeTap,
            videoButtonState: videoButtonState,
            videoButtonEnabled: videoButtonEnabled,
            minimizeButtonEnabled: minimizeButtonEnabled
        )
    }
}

#endif

#if DEBUG

extension CallVisualizer.VideoCallView.CallButtonBar.Props {
    static func mock(
        style: CallButtonBarStyle = .mock,
        videoButtonTap: Cmd = .nop,
        minimizeTap: Cmd = .nop
    ) -> CallVisualizer.VideoCallView.CallButtonBar.Props {
        .init(
            style: style,
            videoButtonTap: videoButtonTap,
            minimizeTap: minimizeTap
        )
    }
}

#endif

#if DEBUG

extension CallVisualizer.VideoCallView.CallButtonBar.Props {
    static let mock = Self(
        style: .mock,
        videoButtonTap: .nop,
        minimizeTap: .nop
    )
}

#endif

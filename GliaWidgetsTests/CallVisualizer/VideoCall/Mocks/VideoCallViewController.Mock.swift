#if DEBUG

extension CallVisualizer.VideoCallViewController {
    static func mock(
        props: Props = .init(videoCallViewProps: .mock()),
        environment: CallVisualizer.VideoCallViewController.Environment = .init(
            videoCallView: .mock,
            uiApplication: .mock,
            uiScreen: .mock,
            uiDevice: .mock,
            notificationCenter: .mock
        )
    ) -> CallVisualizer.VideoCallViewController {
        .init(
            props: props,
            environment: environment
        )
    }
}

#endif

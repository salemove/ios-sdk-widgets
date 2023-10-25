#if DEBUG

extension CallVisualizer.VideoCallViewController {
    static func mock(
        props: Props = .init(videoCallViewProps: .mock(), viewDidLoad: .nop),
        environment: CallVisualizer.VideoCallViewController.Environment = .init(
            videoCallView: .mock,
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

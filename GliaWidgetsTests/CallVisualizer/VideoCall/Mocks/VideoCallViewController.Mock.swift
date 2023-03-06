#if DEBUG

extension CallVisualizer.VideoCallViewController {
    static func mock(
        props: Props = .init(videoCallViewProps: .mock()),
        environment: CallVisualizer.VideoCallView.Environment = .mock
    ) -> CallVisualizer.VideoCallViewController {
        .init(
            props: props,
            environment: environment
        )
    }
}

#endif

#if DEBUG

extension CallVisualizer.VideoCallView.ConnectOperatorView.Props {
    static let mock = Self(
        style: .mock,
        size: .init(size: .normal, animated: false),
        operatorAnimate: false,
        userImageViewProps: .mock)
}

#endif

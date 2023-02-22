#if DEBUG

extension Header.Props {
    static func mock(
        title: String = "",
        effect: Header.Effect = .none,
        endButton: ActionButton.Props = .init(),
        backButton: HeaderButton.Props = .init(style: .mock),
        closeButton: HeaderButton.Props = .init(style: .mock),
        endScreenShareButton: HeaderButton.Props = .init(style: .mock),
        style: HeaderStyle = .mock
    ) -> Header.Props {
        .init(
            title: title,
            effect: effect,
            endButton: endButton,
            backButton: backButton,
            closeButton: closeButton,
            endScreenshareButton: endScreenShareButton,
            style: style
        )
    }
}

#endif

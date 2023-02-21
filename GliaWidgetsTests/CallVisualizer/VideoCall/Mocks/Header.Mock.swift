#if DEBUG

extension Header.Props {
    static let mock = Self(
        title: "",
        effect: .none,
        endButton: .init(),
        backButton: .init(style: .mock),
        closeButton: .init(style: .mock),
        endScreenshareButton: .init(style: .mock),
        style: .mock
    )
}

#endif

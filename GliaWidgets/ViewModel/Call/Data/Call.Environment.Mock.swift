#if DEBUG
extension Call.Environment {
    static let mock = Self(
        audioSession: .mock,
        uuid: { .mock }
    )
}
#endif

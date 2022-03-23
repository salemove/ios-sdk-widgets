#if DEBUG
extension CallViewModel.Environment {
    static let mock = Self(timerProviding: .mock)
}
#endif

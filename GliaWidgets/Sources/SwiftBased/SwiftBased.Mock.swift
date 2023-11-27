#if DEBUG
extension SwiftBased.Print {
    static let mock = Self(printClosure: { _, _, _ in })
}
#endif

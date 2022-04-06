#if DEBUG
extension ImageView.Cache {
    static let mock = Self(
        setImageForKey: { _, _ in },
        getImageForKey: { _ in nil }
    )
}
#endif

#if DEBUG
extension ChatOperator {
    static func mock(
        name: String = "",
        pictureUrl: String? = nil
    ) -> ChatOperator {
        ChatOperator(
            name: name,
            pictureUrl: pictureUrl
        )
    }
}
#endif

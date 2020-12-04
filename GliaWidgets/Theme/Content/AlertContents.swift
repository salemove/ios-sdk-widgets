public struct AlertContents {
    public var unexpectedError: AlertMessageContent

    public init(unexpectedError: AlertMessageContent) {
        self.unexpectedError = unexpectedError
    }
}

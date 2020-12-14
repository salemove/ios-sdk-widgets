public struct AlertStrings {
    public var unexpectedError: AlertMessageStrings
    public var leaveQueue: AlertConfirmationStrings

    public init(unexpectedError: AlertMessageStrings,
                leaveQueue: AlertConfirmationStrings) {
        self.unexpectedError = unexpectedError
        self.leaveQueue = leaveQueue
    }
}

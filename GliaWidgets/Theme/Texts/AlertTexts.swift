public struct AlertTexts {
    public var unexpectedError: AlertMessageTexts
    public var leaveQueue: AlertConfirmationTexts

    public init(unexpectedError: AlertMessageTexts,
                leaveQueue: AlertConfirmationTexts) {
        self.unexpectedError = unexpectedError
        self.leaveQueue = leaveQueue
    }
}

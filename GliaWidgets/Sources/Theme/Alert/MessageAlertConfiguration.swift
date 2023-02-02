/// Configuration of a generic alert.
public struct MessageAlertConfiguration {
    /// Title of the alert.
    public var title: String?

    /// Message of the alert. Include `{message}` template parameter in the string to display Glia's error message.
    public var message: String?

    private let kMessagePlaceholder = "{message}"

    ///
    /// - Parameters:
    ///   - title: Title of the alert.
    ///   - message: Message of the alert. Include `{message}` template parameter in the string to display Glia's error message.
    ///
    public init(title: String?, message: String?) {
        self.title = title
        self.message = message
    }

    init(with error: CoreSdkClient.SalemoveError, templateConf: MessageAlertConfiguration) {
        self.title = templateConf.title
        self.message = templateConf.message?.replacingOccurrences(of: kMessagePlaceholder,
                                                                  with: error.reason)
    }
}

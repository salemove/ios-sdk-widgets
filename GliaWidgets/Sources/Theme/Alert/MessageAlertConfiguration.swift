/// Configuration of a generic alert.
public struct MessageAlertConfiguration {
    /// Title of the alert.
    public var title: String?

    /// Message of the alert. Include `{message}` template parameter 
    /// in the string to display Glia's error message.
    public var message: String?

    /// Controls the appearance of the X button in the alert. Defaults to true. 
    /// If this value is true, an X button shows up on the alert so that the visitor
    /// can dismiss it, and the background gets dimmed. If the value is false, no X button
    /// shows up, and the background doesn't get dimmed.
    ///
    public var shouldShowCloseButton = true

    private let kMessagePlaceholder = "{message}"

    /// - Parameters:
    ///   - title: Title of the alert.
    ///   - message: Message of the alert. Include `{message}` template parameter in the string to 
    ///     display Glia's error message.
    ///   - shouldShowCloseButton: Controls the appearance of the X button in the alert.
    ///     Defaults to true. If this value is true, an X button shows up on the alert so that the
    ///     visitor can dismiss it, and the background gets dimmed. If the value is false,
    ///     no X button shows up, and the background doesn't get dimmed.
    ///
    public init(
        title: String?,
        message: String?,
        shouldShowCloseButton: Bool = true
    ) {
        self.title = title
        self.message = message
        self.shouldShowCloseButton = shouldShowCloseButton
    }

    init(
        with error: CoreSdkClient.SalemoveError,
        templateConf: MessageAlertConfiguration
    ) {
        self.title = templateConf.title
        self.message = templateConf.message?.replacingOccurrences(
            of: kMessagePlaceholder,
            with: error.reason
        )
        self.shouldShowCloseButton = templateConf.shouldShowCloseButton
    }
}

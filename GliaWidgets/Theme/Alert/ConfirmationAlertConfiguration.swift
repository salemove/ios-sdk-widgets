/// Configuration of a confirmation alert.
public struct ConfirmationAlertConfiguration {
    /// Title of the alert.
    public var title: String?

    /// Message of the alert.
    public var message: String?

    /// Title of a negative action button.
    public var negativeTitle: String?

    /// Title of a positive action button.
    public var positiveTitle: String?

    /// Indicates whether action button's colors should be switched.
    public var switchButtonBackgroundColors = false

    /// Controls the appearance of the "Powered by" text and logo in the alert.
    public var showsPoweredBy: Bool
}

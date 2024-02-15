import Foundation

/// Configuration of the confirmation alert.
public struct ConfirmationAlertConfiguration {
    /// Title of the alert.
    public var title: String?

    /// Message of the alert.
    public var message: String?

    /// First link button url value.
    public var firstLinkButtonUrl: String?

    /// Second link button url value.
    public var secondLinkButtonUrl: String?

    /// Title of the negative action button.
    public var negativeTitle: String?

    /// Title of the positive action button.
    public var positiveTitle: String?

    /// Indicates whether the action button's colors should be switched.
    public var switchButtonBackgroundColors = false

    /// Controls the appearance of the "Powered by" text and logo in the alert.
    public var showsPoweredBy: Bool
}

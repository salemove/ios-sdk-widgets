import Foundation

/// Configuration of the operator ending the engagement alert.
public struct SingleActionAlertConfiguration: Equatable {
    /// Title of the alert.
    public var title: String?

    /// Message of the alert.
    public var message: String?

    /// Title of the button.
    public var buttonTitle: String?
}

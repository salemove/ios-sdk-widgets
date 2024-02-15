import UIKit
import GliaCoreSDK

/// Message renderer for AI custom cards.
public struct MessageRenderer {
    /// Closure returning the custom card view for the message.
    public var render: (Message) -> UIView?

    /// Closure returning boolean value indicating whether the custom 
    /// card view is interactable.
    public var isInteractable: (Message) -> Bool

    /// Closure returning boolean value indicating the custom card view
    /// should be shown when the card is interactable and option is selected.
    public var shouldShowCard: (Message) -> Bool

    /// Void closure that receives selected string-based mobile action.
    public var callMobileActionHandler: (String) -> Void

    /// - Parameters:
    ///   - render: Closure returning the custom card view for the message.
    ///   - isInteractable: Closure returning boolean value indicating whether the custom card view is interactable.
    ///   - shouldShowCard: Closure returning boolean value indicating the custom card view should 
    ///     be shown when the card is interactable and option is selected.
    ///   - callMobileActionHandler: Void closure that receives selected string-based mobile action.
    ///
    public init(
        render: @escaping (Message) -> UIView?,
        isInteractable: @escaping (Message) -> Bool = { _ in false },
        shouldShowCard: @escaping (Message) -> Bool = { _ in true },
        callMobileActionHandler: @escaping (String) -> Void = { _ in }
    ) {
        self.render = render
        self.isInteractable = isInteractable
        self.shouldShowCard = shouldShowCard
        self.callMobileActionHandler = callMobileActionHandler
    }
}

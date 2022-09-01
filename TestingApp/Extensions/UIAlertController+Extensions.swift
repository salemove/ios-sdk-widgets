import UIKit

extension UIAlertController {
    struct PopoverSettings {
        let delegate: UIPopoverPresentationControllerDelegate?
        let permittedArrowDirections: UIPopoverArrowDirection
        let sourceView: UIView?
        let sourceRect: CGRect
        /// By default, a popover is not allowed to overlap its source view rect.
        /// When this is set to YES, popovers with more content than available space are allowed to overlap the source view rect in order to accommodate the content.
        let canOverlapSourceViewRect: Bool
        let barButtonItem: UIBarButtonItem?
        /// By default, a popover disallows interaction with any view outside of the popover while the popover is presented.
        /// This property allows the specification of an array of UIView instances which the user is allowed to interact with
        /// while the popover is up.
        let passthroughViews: [UIView]?
        // Set popover background color. Set to nil to use default background color. Default is nil.
        let backgroundColor: UIColor?
        /// Clients may wish to change the available area for popover display. The default implementation of this method always
        /// returns insets which define 10 points from the edges of the display, and presentation of popovers always accounts
        /// for the status bar. The rectangle being inset is always expressed in terms of the current device orientation; (0, 0)
        /// is always in the upper-left of the device. This may require insets to change on device rotation.
        let popoverLayoutMargins: UIEdgeInsets
        /// Clients may customize the popover background chrome by providing a class which subclasses `UIPopoverBackgroundView`
        /// and which implements the required instance and class methods on that class.
        let popoverBackgroundViewClass: UIPopoverBackgroundViewMethods.Type?

        init(
            delegate: UIPopoverPresentationControllerDelegate? = nil,
            permittedArrowDirections: UIPopoverArrowDirection = .any,
            sourceView: UIView? = nil,
            sourceRect: CGRect = .zero,
            canOverlapSourceViewRect: Bool = false,
            barButtonItem: UIBarButtonItem? = nil,
            passthroughViews: [UIView]? = nil,
            backgroundColor: UIColor? = nil,
            popoverLayoutMargins: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10),
            popoverBackgroundViewClass: UIPopoverBackgroundViewMethods.Type? = nil
        ) {
            self.delegate = delegate
            self.permittedArrowDirections = permittedArrowDirections
            self.sourceView = sourceView
            self.sourceRect = sourceRect
            self.canOverlapSourceViewRect = canOverlapSourceViewRect
            self.barButtonItem = barButtonItem
            self.passthroughViews = passthroughViews
            self.backgroundColor = backgroundColor
            self.popoverLayoutMargins = popoverLayoutMargins
            self.popoverBackgroundViewClass = popoverBackgroundViewClass
        }
    }

    /// Presents alert controller in safe way, meaning that if it is configured as action sheet,
    /// it will be presented in pop-over, effectively avoiding crash, when app is run with iPad support on.
    /// On iPhone it will have no effect (presented as usual action sheet).
    func presented(
        in viewController: UIViewController,
        animated: Bool = true,
        popoverSettings: PopoverSettings? = nil,
        userInterfaceIdiom: () -> UIUserInterfaceIdiom = { UIScreen.main.traitCollection.userInterfaceIdiom },
        completion: (() -> Void)? = nil
    ) {
        switch userInterfaceIdiom() {
        case .phone:
            viewController.present(self, animated: animated, completion: completion)
        case .pad:
            if let settings = popoverSettings, let popover = self.popoverPresentationController {
                popover.delegate = settings.delegate
                popover.permittedArrowDirections = settings.permittedArrowDirections
                popover.sourceView = settings.sourceView ?? viewController.view
                popover.sourceRect = settings.sourceRect
                popover.canOverlapSourceViewRect = settings.canOverlapSourceViewRect
                popover.barButtonItem = settings.barButtonItem
                popover.passthroughViews = settings.passthroughViews
                popover.backgroundColor = settings.backgroundColor
                popover.popoverLayoutMargins = settings.popoverLayoutMargins
                popover.popoverBackgroundViewClass = settings.popoverBackgroundViewClass
            } else {
                // Perform minimal configuration to prevent crashing.
                popoverPresentationController?.sourceView = viewController.view
            }

            viewController.present(self, animated: animated, completion: completion)
        default:
            debugPrint("Unable to present action sheet: unsupported userInterfaceIdiom '\(userInterfaceIdiom())'")
        }
    }
}

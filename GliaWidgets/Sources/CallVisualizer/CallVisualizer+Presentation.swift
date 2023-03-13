import UIKit

extension CallVisualizer {
    public enum Presentation {
        case alert(UIViewController)
        case embedded(
            UIView,
            onEngagementAccepted: (() -> Void)
        )
    }
}

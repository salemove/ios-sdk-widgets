import UIKit

extension CallVisualizer {
    enum Presentation {
        case alert(UIViewController)
        case embedded(
            UIView,
            onEngagementAccepted: (() -> Void)
        )
    }
}

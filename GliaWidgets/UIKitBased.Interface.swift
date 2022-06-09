import UIKit

enum UIKitBased {
    struct UIImage {
        var imageWithContentsOfFileAtPath: (String) -> UIKit.UIImage?
    }

    struct UIApplication {
        var open: (URL) -> Void
        var canOpenURL: (URL) -> Bool
    }
}

import UIKit

extension UIView {
    var screenshot: UIImage? {
        var viewScreenshot: UIImage?

        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: bounds.width, height: bounds.height),
            false,
            0
        )
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        viewScreenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return viewScreenshot
    }
}

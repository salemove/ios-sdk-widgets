import UIKit

extension UIView {
    var screenshot: UIImage? {
        var viewScreenshot: UIImage?

        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: bounds.width, height: bounds.height),
            false,
            2
        )

        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            viewScreenshot = UIGraphicsGetImageFromCurrentImageContext()
        }

        UIGraphicsEndImageContext()

        return viewScreenshot
    }
}

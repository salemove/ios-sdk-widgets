import UIKit
import AVFoundation

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let originalSize = self.size
        let sizeToCrop = size

        // Determining what rect should be cropped
        var scale = sizeToCrop.width / originalSize.width
        if originalSize.height * scale < sizeToCrop.height {
            scale = sizeToCrop.height / originalSize.height
        }
        let croppedSize = CGSize(
            width: sizeToCrop.width / scale,
            height: sizeToCrop.height / scale
        )
        let croppedRect = CGRect(
            origin: CGPoint(
                x: (originalSize.width - croppedSize.width) / 2.0,
                y: (originalSize.height - croppedSize.height) / 2.0
            ),
            size: croppedSize
        )

        func rad(_ degree: Double) -> CGFloat {
            return CGFloat(degree / 180.0 * .pi)
        }

        // Adding transformation to fix losing image orientation while cropping an image
        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90))
                .translatedBy(x: 0, y: -self.size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90))
                .translatedBy(x: -self.size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180))
                .translatedBy(x: -self.size.width, y: -self.size.height)
        default:
            rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)

        guard let croppedCGImage = self.cgImage?.cropping(to: croppedRect.applying(rectTransform)) else {
            return nil
        }

        return UIImage(
            cgImage: croppedCGImage,
            scale: 1,
            orientation: self.imageOrientation
        )
    }

    func image(withTintColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.normal)
        let rect: CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        guard let cgImage = self.cgImage else {
            return UIImage()
        }
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return newImage
    }
}

import UIKit
import func AVFoundation.AVMakeRect

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let scaleFactor = UIScreen.main.scale
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        let targetSize = size.applying(scale)
        let rect = AVMakeRect(aspectRatio: self.size,
                              insideRect: CGRect(origin: .zero, size: targetSize))
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: rect.size))
        }
    }
}

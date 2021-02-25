import UIKit
import func AVFoundation.AVMakeRect

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let rect = AVMakeRect(aspectRatio: self.size,
                              insideRect: CGRect(origin: .zero, size: size))
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: rect.size))
        }
    }
}

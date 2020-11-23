import UIKit

typealias TouchAreaInsets = (dx: CGFloat, dy: CGFloat)

protocol ButtonProperties {
    var title: String? { get }
    var useImageSize: Bool { get }
    var width: CGFloat? { get }
    var height: CGFloat? { get }
    var cornerRadius: CGFloat? { get }
    var borderWidth: CGFloat? { get }
    var borderColor: UIColor? { get }
    var backgroundColor: UIColor? { get }
    var font: UIFont? { get }
    var fontColor: UIColor? { get }
    var image: UIImage? { get }
    var touchAreaInsets: TouchAreaInsets? { get }
    var shadowColor: UIColor? { get }
    var shadowOffset: CGSize? { get }
    var shadowOpacity: Float? { get }
    var shadowRadius: CGFloat? { get }
    var contentEdgeInsets: UIEdgeInsets? { get }
    var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment? { get }
    var contentVerticalAlignment: UIControl.ContentVerticalAlignment? { get }
    var imageEdgeInsets: UIEdgeInsets? { get }
}

extension ButtonProperties {
    var title: String? { nil }
    var useImageSize: Bool { true }
    var width: CGFloat? { useImageSize ? image?.size.width : nil }
    var height: CGFloat? { useImageSize ? image?.size.height : nil }
    var cornerRadius: CGFloat? { nil }
    var borderWidth: CGFloat? { nil }
    var borderColor: UIColor? { nil }
    var backgroundColor: UIColor? { nil }
    var font: UIFont? { nil }
    var fontColor: UIColor? { nil }
    var image: UIImage? { nil }
    var touchAreaInsets: TouchAreaInsets? { nil }
    var shadowColor: UIColor? { nil }
    var shadowOffset: CGSize? { nil }
    var shadowOpacity: Float? { nil }
    var shadowRadius: CGFloat? { nil }
    var contentEdgeInsets: UIEdgeInsets? { nil }
    var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment? { nil }
    var contentVerticalAlignment: UIControl.ContentVerticalAlignment? { nil }
    var imageEdgeInsets: UIEdgeInsets? { nil }
}

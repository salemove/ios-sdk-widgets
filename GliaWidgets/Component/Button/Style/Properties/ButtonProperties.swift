import UIKit

typealias TouchAreaInsets = (dx: CGFloat, dy: CGFloat)

protocol ButtonProperties {
    var title: String? { get }
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
    var title: String? { return nil }
    var width: CGFloat? { return nil }
    var height: CGFloat? { return nil }
    var cornerRadius: CGFloat? { return nil }
    var borderWidth: CGFloat? { return nil }
    var borderColor: UIColor? { return nil }
    var backgroundColor: UIColor? { return nil }
    var font: UIFont? { return nil }
    var fontColor: UIColor? { return nil }
    var image: UIImage? { return nil }
    var touchAreaInsets: TouchAreaInsets? { return nil }
    var shadowColor: UIColor? { return nil }
    var shadowOffset: CGSize? { return nil }
    var shadowOpacity: Float? { return nil }
    var shadowRadius: CGFloat? { return nil }
    var contentEdgeInsets: UIEdgeInsets? { return nil }
    var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment? { return nil }
    var contentVerticalAlignment: UIControl.ContentVerticalAlignment? { return nil }
    var imageEdgeInsets: UIEdgeInsets? { return nil }
}

import UIKit

/// Defines layout specific properties. This interface helps to make
///  flexible mechanism for defining UI and avoid make strict relations
///  with UIView.
public protocol Layoutable {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }

    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }

    var heightAnchor: NSLayoutDimension { get }
    var widthAnchor: NSLayoutDimension { get }

    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: Layoutable {}
extension UILayoutGuide: Layoutable {}

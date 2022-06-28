import UIKit

public class OperatorTypingIndicatorStyle {
    /// Color of the operator typing indicator.
    public let color: UIColor
    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// 
    /// - Parameters:
    ///   - color: Color of the operator typing indicator.
    ///   - accessibility: Accessibility related properties.
    public init(
        color: UIColor,
        accessibility: Accessibility = .unsupported
    ) {
        self.color = color
        self.accessibility = accessibility
    }
}

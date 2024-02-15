import UIKit

/// Style of the operator typing indicator, which consists of 3 bouncing dots.
/// It appears in the chat container when operator is typing a message.
public class OperatorTypingIndicatorStyle {
    /// Color of the operator typing indicator.
    public var color: UIColor

    /// Accessibility related properties.
    public var accessibility: Accessibility

    /// - Parameters:
    ///   - color: Color of the operator typing indicator.
    ///   - accessibility: Accessibility related properties.
    ///
    public init(
        color: UIColor,
        accessibility: Accessibility = .unsupported
    ) {
        self.color = color
        self.accessibility = accessibility
    }
}

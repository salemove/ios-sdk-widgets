import UIKit

/// Base style for file content.
public class ChatFileContentStyle {
    /// Background color of the content view.
    public var backgroundColor: UIColor
    /// Accessibility releated properties.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - backgroundColor: Background color of the content view.
    ///   - accessibility: Accessibility releated properties.
    public init(
        backgroundColor: UIColor,
        accessibility: Accessibility = .unsupported
    ) {
        self.backgroundColor = backgroundColor
        self.accessibility = accessibility
    }
}

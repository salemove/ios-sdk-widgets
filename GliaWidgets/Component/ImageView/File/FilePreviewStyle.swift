import UIKit

/// Style of a file preview.
///
/// Appears in message input area before sending the files or in the incoming messages to preview downloads (except for images).
public class FilePreviewStyle {
    /// Font of the file extension label text.
    public var fileFont: UIFont

    /// Color of the file extension label text.
    public var fileColor: UIColor

    /// Icon of the error state.
    public var errorIcon: UIImage?

    /// Color of the error icon.
    public var errorIconColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    /// Background color of the view in the error state.
    public var errorBackgroundColor: UIColor

    ///
    /// - Parameters:
    ///   - fileFont: Font of the file extension label text.
    ///   - fileColor: Color of the file extension label text.
    ///   - errorIcon: Icon of the error state.
    ///   - errorIconColor: Color of the error icon.
    ///   - backgroundColor: Background color of the view.
    ///   - errorBackgroundColor: Background color of the view in the error state.
    ///
    public init(
        fileFont: UIFont,
        fileColor: UIColor,
        errorIcon: UIImage?,
        errorIconColor: UIColor,
        backgroundColor: UIColor,
        errorBackgroundColor: UIColor
    ) {
        self.fileFont = fileFont
        self.fileColor = fileColor
        self.errorIcon = errorIcon
        self.errorIconColor = errorIconColor
        self.backgroundColor = backgroundColor
        self.errorBackgroundColor = errorBackgroundColor
    }
}

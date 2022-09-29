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
    public var errorIcon: UIImage

    /// Color of the error icon.
    public var errorIconColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    /// Background color of the view in the error state.
    public var errorBackgroundColor: UIColor

    /// Corner radius of the view.
    public var cornerRadius: CGFloat

    /// Accessiblity properties for CallStyle.
    public var accessibility: Accessibility

    ///
    /// - Parameters:
    ///   - fileFont: Font of the file extension label text.
    ///   - fileColor: Color of the file extension label text.
    ///   - errorIcon: Icon of the error state.
    ///   - errorIconColor: Color of the error icon.
    ///   - backgroundColor: Background color of the view.
    ///   - errorBackgroundColor: Background color of the view in the error state.
    ///   - cornerRadius: Corner radius of the view.
    ///   - accessibility: Accessiblity properties for CallStyle.
    ///
    public init(
        fileFont: UIFont,
        fileColor: UIColor,
        errorIcon: UIImage,
        errorIconColor: UIColor,
        backgroundColor: UIColor,
        errorBackgroundColor: UIColor,
        cornerRadius: CGFloat = 4,
        accessibility: Accessibility = .unsupported
    ) {
        self.fileFont = fileFont
        self.fileColor = fileColor
        self.errorIcon = errorIcon
        self.errorIconColor = errorIconColor
        self.backgroundColor = backgroundColor
        self.errorBackgroundColor = errorBackgroundColor
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
    }

    func apply(configuration: RemoteConfiguration.FilePreview?) {
        configuration?.background?.cornerRadius
            .map { cornerRadius = $0 }

        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .map { backgroundColor = $0 }

        configuration?.errorBackground?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .map { errorBackgroundColor = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { fileColor = $0 }

        configuration?.text?.font?.size
            .map { fileFont = Font.regular($0) }

        configuration?.errorIcon?.value
            .map { UIColor(hex: $0) }
            .first
            .map { errorIconColor = $0 }
    }
}

#if DEBUG
extension FilePreviewStyle {
    static var mock: FilePreviewStyle {
        FilePreviewStyle(
            fileFont: .systemFont(ofSize: 10),
            fileColor: .clear,
            errorIcon: UIImage(),
            errorIconColor: .clear,
            backgroundColor: .clear,
            errorBackgroundColor: .clear,
            accessibility: .unsupported
        )
    }
}
#endif

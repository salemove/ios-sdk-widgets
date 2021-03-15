import UIKit

public class FilePreviewImageStyle {
    public var fileFont: UIFont
    public var fileColor: UIColor
    public var errorIcon: UIImage
    public var errorIconColor: UIColor
    public var backgroundColor: UIColor
    public var errorBackgroundColor: UIColor

    public init(fileFont: UIFont,
                fileColor: UIColor,
                errorIcon: UIImage,
                errorIconColor: UIColor,
                backgroundColor: UIColor,
                errorBackgroundColor: UIColor) {
        self.fileFont = fileFont
        self.fileColor = fileColor
        self.errorIcon = errorIcon
        self.errorIconColor = errorIconColor
        self.backgroundColor = backgroundColor
        self.errorBackgroundColor = errorBackgroundColor
    }
}

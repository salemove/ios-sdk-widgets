import UIKit

public class FileUploadStyle {
    public var fileFont: UIFont
    public var fileColor: UIColor
    public var statusFont: UIFont
    public var statusColor: UIColor
    public var errorFont: UIFont
    public var errorColor: UIColor
    public var cancelButtonImage: UIImage
    public var cancelButtonColor: UIColor

    public init(fileFont: UIFont,
                fileColor: UIColor,
                statusFont: UIFont,
                statusColor: UIColor,
                errorFont: UIFont,
                errorColor: UIColor,
                cancelButtonImage: UIImage,
                cancelButtonColor: UIColor) {
        self.fileFont = fileFont
        self.fileColor = fileColor
        self.statusFont = statusFont
        self.statusColor = statusColor
        self.errorFont = errorFont
        self.errorColor = errorColor
        self.cancelButtonImage = cancelButtonImage
        self.cancelButtonColor = cancelButtonColor
    }
}

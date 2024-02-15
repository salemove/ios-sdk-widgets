import Foundation

extension AttachmentSourceItemStyle {
    public static func == (lhs: AttachmentSourceItemStyle, rhs: AttachmentSourceItemStyle) -> Bool {
        lhs.kind == rhs.kind &&
        lhs.title == rhs.title &&
        lhs.titleFont == rhs.titleFont &&
        lhs.titleColor == rhs.titleColor &&
        lhs.titleTextStyle == rhs.titleTextStyle &&
        lhs.icon == rhs.icon &&
        lhs.iconColor == rhs.iconColor &&
        lhs.accessibility == rhs.accessibility
    }
}

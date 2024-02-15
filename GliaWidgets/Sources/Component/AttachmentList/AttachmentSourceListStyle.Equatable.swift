import Foundation

extension AttachmentSourceListStyle {
    public static func == (lhs: AttachmentSourceListStyle, rhs: AttachmentSourceListStyle) -> Bool {
        lhs.items == rhs.items &&
        lhs.separatorColor == rhs.separatorColor &&
        lhs.backgroundColor == rhs.backgroundColor
    }
}

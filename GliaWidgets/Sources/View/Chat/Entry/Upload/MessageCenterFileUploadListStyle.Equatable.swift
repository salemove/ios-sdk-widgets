import Foundation

extension MessageCenterFileUploadListStyle {
    public static func == (
        lhs: MessageCenterFileUploadListStyle,
        rhs: MessageCenterFileUploadListStyle
    ) -> Bool {
        lhs.item == rhs.item
    }
}

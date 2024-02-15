import Foundation

extension FileUploadListStyle {
    public static func == (lhs: FileUploadListStyle, rhs: FileUploadListStyle) -> Bool {
        lhs.item == rhs.item
    }
}

import Foundation

extension UnreadMessageDividerStyle {
    public static func == (lhs: UnreadMessageDividerStyle, rhs: UnreadMessageDividerStyle) -> Bool {
        return lhs.title == rhs.title &&
        lhs.titleColor == rhs.titleColor &&
        lhs.titleFont == rhs.titleFont &&
        lhs.lineColor == rhs.lineColor
    }
}

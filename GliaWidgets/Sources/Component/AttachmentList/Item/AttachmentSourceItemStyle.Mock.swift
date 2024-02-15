import UIKit

#if DEBUG
extension AttachmentSourceItemStyle {
    static func mock(with kind: AttachmentSourceItemKind) -> AttachmentSourceItemStyle {
        let theme = Theme()
        let titleFont = theme.font.bodyText
        let titleColor = theme.color.baseDark
        let iconColor = theme.color.baseDark
        var title: String
        var icon: UIImage

        switch kind {
        case .photoLibrary:
            title = "Photo Library"
            icon = Asset.photoLibraryIcon.image
        case .takePhoto:
            title = "Take phone"
            icon = Asset.cameraIcon.image
        case .browse:
            title = "Browse"
            icon = Asset.browseIcon.image
        }

        let item: AttachmentSourceItemStyle = .init(
            kind: kind,
            title: title,
            titleFont: titleFont,
            titleColor: titleColor,
            icon: icon,
            iconColor: iconColor,
            accessibility: .init(isFontScalingEnabled: true)
        )

        return item
    }
}
#endif

import UIKit

#if DEBUG
extension AttachmentSourceListStyle {
    static func mock() -> AttachmentSourceListStyle {
        let theme = Theme()
        let style: AttachmentSourceListStyle = .init(
            items: [
                .mock(with: .browse),
                .mock(with: .photoLibrary),
                .mock(with: .takePhoto)
            ],
            separatorColor: theme.color.baseShade,
            backgroundColor: theme.color.baseNeutral
        )

        return style
    }
}
#endif

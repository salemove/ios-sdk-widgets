import UIKit

extension Theme {
    var gliaVirtualAssistantStyle: GliaVirtualAssistantStyle {
        let font = ThemeFontStyle.default.font

        let persistentButton: GvaPersistentButtonStyle = .init(
            title: .init(
                text: .init(
                    color: UIColor.black.hex,
                    font: font.bodyText,
                    textStyle: .headline,
                    accessibility: .init(isFontScalingEnabled: true)
                ),
                background: .init(
                    background: .fill(color: .clear),
                    borderColor: .clear,
                    borderWidth: .zero,
                    cornerRadius: 8.49
                ),
                accessibility: .init(isFontScalingEnabled: true)
            ),
            backgroundColor: .fill(color: color.baseNeutral),
            cornerRadius: 10,
            borderWidth: 0,
            borderColor: .clear,
            button: .init(
                textFont: font.caption,
                textColor: color.baseDark,
                backgroundColor: .fill(color: color.baseLight),
                cornerRadius: 5,
                borderColor: .clear,
                borderWidth: 0,
                accessibility: .init(isFontScalingEnabled: true)
            )
        )

        let quickReplyButton: GvaQuickReplyButtonStyle = .init(
            textFont: font.buttonLabel,
            textColor: color.primary,
            backgroundColor: .fill(color: color.baseLight),
            cornerRadius: 10,
            borderColor: color.primary,
            borderWidth: 1
        )

        let galleryCard: GvaGalleryCardStyle = .init(
            cardContainer: .init(
                backgroundColor: .fill(color: color.baseNeutral),
                cornerRadius: 8,
                borderColor: .clear,
                borderWidth: 0
            ),
            imageView: .init(
                backgroundColor: .fill(color: .clear),
                cornerRadius: 8,
                borderColor: .clear,
                borderWidth: 0
            ),
            title: .init(
                font: font.mediumSubtitle1,
                textColor: color.baseDark,
                textStyle: .body
            ),
            subtitle: .init(
                font: font.caption,
                textColor: color.baseDark,
                textStyle: .caption1
            ),
            button: .init(
                title: .init(
                    font: font.caption,
                    textColor: color.baseDark,
                    textStyle: .caption1
                ),
                background: .init(
                    backgroundColor: .fill(color: color.baseLight),
                    cornerRadius: 8,
                    borderColor: .clear,
                    borderWidth: 0
                )
            )
        )

        let operatorImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: .fill(color: color.primary),
            imageBackgroundColor: .fill(color: .clear),
            transferringImage: Asset.operatorTransferring.image
        )

        let galleryList: GvaGalleryListViewStyle = .init(
            operatorImage: operatorImage,
            cardStyle: galleryCard
        )

        return .init(
            persistentButton: persistentButton,
            quickReplyButton: quickReplyButton,
            galleryList: galleryList
        )
    }
}

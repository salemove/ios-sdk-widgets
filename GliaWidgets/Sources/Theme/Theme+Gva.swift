import UIKit

extension Theme {
    var gliaVirtualAssistantStyle: GliaVirtualAssistantStyle {
        let font = ThemeFontStyle.default.font

        let persistentButton: GvaPersistentButtonStyle = .init(
            title: .init(
                textFont: font.bodyText,
                textColor: .black,
                textStyle: .body,
                backgroundColor: .clear,
                accessibility: .init(isFontScalingEnabled: true)
            ),
            backgroundColor: .fill(color: color.lightGrey),
            cornerRadius: 10,
            borderWidth: 0,
            borderColor: .clear,
            button: .init(
                textFont: font.caption,
                textColor: .black,
                backgroundColor: .fill(color: color.background),
                cornerRadius: 5,
                borderColor: .clear,
                borderWidth: 0,
                accessibility: .init(isFontScalingEnabled: true)
            )
        )

        let quickReplyButton: GvaQuickReplyButtonStyle = .init(
            textFont: font.buttonLabel,
            textColor: Color.primary,
            backgroundColor: .fill(color: Color.baseLight),
            cornerRadius: 10,
            borderColor: Color.primary,
            borderWidth: 1
        )

        let galleryCard: GvaGalleryCardStyle = .init(
            cardContainer: .init(
                backgroundColor: .fill(color: color.lightGrey),
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
                font: font.bodyText,
                textColor: .black,
                textStyle: .body
            ),
            subtitle: .init(
                font: font.caption,
                textColor: .black,
                textStyle: .caption1
            ),
            button: .init(
                title: .init(
                    font: font.caption,
                    textColor: .black,
                    textStyle: .caption1
                ),
                background: .init(
                    backgroundColor: .fill(color: color.background),
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

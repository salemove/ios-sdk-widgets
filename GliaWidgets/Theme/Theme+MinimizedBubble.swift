extension Theme {
    var minimizedBubbleStyle: BubbleStyle {
        let userImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: color.primary,
            imageBackgroundColor: color.primary,
            transferringImage: Asset.operatorTransferring.image
        )
        let badge = BadgeStyle(
            font: font.caption,
            fontColor: color.baseLight,
            backgroundColor: color.primary
        )
        let onHoldOverlay = OnHoldOverlayStyle(
            image: Asset.callOnHold.image,
            imageColor: .white,
            imageSize: .init(width: 26, height: 26)
        )
        return BubbleStyle(
            userImage: userImage,
            badge: badge,
            onHoldOverlay: onHoldOverlay
        )
    }
}

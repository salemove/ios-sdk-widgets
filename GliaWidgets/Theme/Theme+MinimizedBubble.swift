extension Theme {
    var minimizedBubbleStyle: BubbleStyle {
        let userImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder.image,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: .fill(color: color.primary),
            imageBackgroundColor: .fill(color: color.primary),
            transferringImage: Asset.operatorTransferring.image
        )
        let badge = BadgeStyle(
            font: font.caption,
            fontColor: color.baseLight,
            backgroundColor: .fill(color: color.primary)
        )
        let onHoldOverlay = OnHoldOverlayStyle(
            image: Asset.callOnHold.image,
            imageColor: .fill(color: .white),
            imageSize: .init(width: 26, height: 26)
        )
        return BubbleStyle(
            userImage: userImage,
            badge: badge,
            onHoldOverlay: onHoldOverlay,
            accessibility: .init(
                label: L10n.Call.Accessibility.Bubble.label,
                hint: L10n.Call.Accessibility.Bubble.hint
            )
        )
    }
}

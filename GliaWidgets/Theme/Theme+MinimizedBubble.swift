extension Theme {
    var minimizedBubbleStyle: BubbleStyle {
        let userImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder,
            placeholderColor: color.baseLight,
            placeholderBackgroundColor: color.primary,
            imageBackgroundColor: color.primary
        )
        let badge = BadgeStyle(
            font: font.caption,
            fontColor: color.baseLight,
            backgroundColor: color.primary
        )
        return BubbleStyle(
            userImage: userImage,
            badge: badge
        )
    }
}

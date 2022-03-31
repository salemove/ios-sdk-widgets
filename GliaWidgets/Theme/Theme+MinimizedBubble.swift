extension Theme {
    var minimizedBubbleStyle: BubbleStyle {
        let userImage = UserImageStyle(
            placeholderImage: Asset.operatorPlaceholder.image,
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
            badge: badge,
            accessibility: .init(
                label: L10n.Call.Accessibility.Bubble.label,
                hint: L10n.Call.Accessibility.Bubble.hint
            )
        )
    }
}

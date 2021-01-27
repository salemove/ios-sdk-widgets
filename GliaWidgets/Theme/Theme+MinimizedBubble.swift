extension Theme {
    var minimizedBubbleStyle: BubbleStyle {
        let userImage = UserImageStyle(placeholderImage: Asset.operatorPlaceholder.image,
                                       placeholderColor: color.baseLight,
                                       backgroundColor: color.primary)
        return BubbleStyle(userImage: userImage)
    }
}

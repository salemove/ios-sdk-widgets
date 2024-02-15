import Foundation

extension Theme.ChoiceCardStyle {
    mutating func apply(
        configuration: RemoteConfiguration.ResponseCard?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        background.apply(configuration: configuration?.background)

        choiceOption.apply(
            configuration: configuration?.option,
            assetsBuilder: assetsBuilder
        )

        text.apply(
            configuration: configuration?.text,
            assetsBuilder: assetsBuilder
        )

        operatorImage.apply(configuration: configuration?.userImage)
    }
}

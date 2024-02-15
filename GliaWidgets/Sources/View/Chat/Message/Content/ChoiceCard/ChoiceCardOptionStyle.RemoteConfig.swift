import Foundation

extension ChoiceCardOptionStyle {
    func apply(
        configuration: RemoteConfiguration.ResponseCardOption?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        normal.apply(
            configuration: configuration?.normal,
            assetsBuilder: assetsBuilder
        )
        selected.apply(
            configuration: configuration?.selected,
            assetsBuilder: assetsBuilder
        )
        disabled.apply(
            configuration: configuration?.disabled,
            assetsBuilder: assetsBuilder
        )
    }
}

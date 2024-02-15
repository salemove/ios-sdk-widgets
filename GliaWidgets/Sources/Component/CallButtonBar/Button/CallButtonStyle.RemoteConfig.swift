import Foundation

extension CallButtonStyle {
    /// Applies remote configuration to the bar button.
    mutating func applyBarButtonConfig(
        button: RemoteConfiguration.BarButtonStates?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        active.apply(
            configuration: button?.active,
            assetsBuilder: assetsBuilder
        )
        inactive.apply(
            configuration: button?.inactive,
            assetsBuilder: assetsBuilder
        )
        selected.apply(
            configuration: button?.selected,
            assetsBuilder: assetsBuilder
        )
    }
}

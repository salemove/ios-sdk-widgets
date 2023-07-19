import UIKit

/// Style of the GVA views
public struct GliaVirtualAssistantStyle {
    /// Style of Persistent Button
    public var persistentButton: GvaPersistentButtonStyle

    public init(
        persistentButton: GvaPersistentButtonStyle
    ) {
        self.persistentButton = persistentButton
    }

    mutating func apply(
        configuration: RemoteConfiguration.Gva?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        persistentButton.apply(
            configuration?.persistentButton,
            assetBuilder: assetBuilder
        )
    }
}

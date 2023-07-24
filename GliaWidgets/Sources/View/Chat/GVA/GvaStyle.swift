import UIKit

/// Style of the GVA views
public struct GliaVirtualAssistantStyle {
    /// Style of Persistent Button
    public var persistentButton: GvaPersistentButtonStyle

    /// Style for Quick Reply buttons.
    public var quickReplyButton: GvaQuickReplyButtonStyle

    /// - Parameters:
    ///   - persistentButton: Style of Persistent Button
    ///   - quickReplyButton: Style for Quick Reply buttons.
    public init(
        persistentButton: GvaPersistentButtonStyle,
        quickReplyButton: GvaQuickReplyButtonStyle
    ) {
        self.persistentButton = persistentButton
        self.quickReplyButton = quickReplyButton
    }

    mutating func apply(
        configuration: RemoteConfiguration.Gva?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        persistentButton.apply(
            configuration?.persistentButton,
            assetBuilder: assetBuilder
        )
        quickReplyButton.apply(
            configuration?.quickReplyButton,
            assetBuilder: assetBuilder
        )
    }
}

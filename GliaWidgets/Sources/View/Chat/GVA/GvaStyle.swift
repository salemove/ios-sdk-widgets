import UIKit

/// Style of the GVA views
public struct GliaVirtualAssistantStyle {
    /// Style of Persistent Button
    public var persistentButton: GvaPersistentButtonStyle

    /// Style for Quick Reply buttons.
    public var quickReplyButtonStyle: GvaQuickReplyButtonStyle

    /// - Parameters:
    ///   - persistentButton: Style of Persistent Button
    ///   - quickReplyButtonStyle: Style for Quick Reply buttons.
    public init(
        persistentButton: GvaPersistentButtonStyle,
        quickReplyButtonStyle: GvaQuickReplyButtonStyle
    ) {
        self.persistentButton = persistentButton
        self.quickReplyButtonStyle = quickReplyButtonStyle
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

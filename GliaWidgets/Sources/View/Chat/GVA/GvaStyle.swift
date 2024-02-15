import UIKit

/// Style of the GVA views
public struct GliaVirtualAssistantStyle {
    /// Style of Persistent Button
    public var persistentButton: GvaPersistentButtonStyle

    /// Style for Quick Reply buttons.
    public var quickReplyButton: GvaQuickReplyButtonStyle

    /// Style for Gallery List.
    public var galleryList: GvaGalleryListViewStyle

    /// - Parameters:
    ///   - persistentButton: Style of Persistent Button
    ///   - quickReplyButton: Style for Quick Reply buttons.
    ///   - galleryCard: Style for Gallery List.
    ///
    public init(
        persistentButton: GvaPersistentButtonStyle,
        quickReplyButton: GvaQuickReplyButtonStyle,
        galleryList: GvaGalleryListViewStyle
    ) {
        self.persistentButton = persistentButton
        self.quickReplyButton = quickReplyButton
        self.galleryList = galleryList
    }
}

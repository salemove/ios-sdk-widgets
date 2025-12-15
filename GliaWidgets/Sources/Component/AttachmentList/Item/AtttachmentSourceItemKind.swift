/// Kind of an item shown in the list view. Used in chat's attachment popover menu.
public enum AttachmentSourceItemKind: String, Equatable {
    /// Photo Library item.
    case photoLibrary

    /// Take Photo or Video item.
    case takePhotoOrVideo

    /// Take Photo item.
    case takePhoto

    /// Take Video item.
    case takeVideo

    /// Browse item.
    case browse
}

extension LocalFile {
    struct Environment {
        var fileManager: FoundationBased.FileManager
        var gcd: GCD
        var uiScreen: UIKitBased.UIScreen
        var thumbnailGenerator: QuickLookBased.ThumbnailGenerator
    }
}

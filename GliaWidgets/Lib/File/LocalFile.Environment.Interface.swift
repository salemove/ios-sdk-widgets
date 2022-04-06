extension LocalFile {
    struct Environment {
        var fileManager: FoundationBased.FileManager
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
    }
}

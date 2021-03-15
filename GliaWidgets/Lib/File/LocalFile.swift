class LocalFile {
    let url: URL
    var isImage: Bool {
        let fileExtension = url.lastPathComponent
        return ["jpg", "jpeg", "png", "gif", "tif", "tiff", "bmp"].contains(fileExtension)
    }

    init(with url: URL) {
        self.url = url
    }
}

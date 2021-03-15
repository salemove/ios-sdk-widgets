class LocalFile {
    let url: URL
    var isImage: Bool { return url.path.hasImageFileExtension }

    init(with url: URL) {
        self.url = url
    }
}

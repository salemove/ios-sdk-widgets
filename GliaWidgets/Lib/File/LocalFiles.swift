class LocalFiles {
    private var files = [URL: LocalFile]()

    init() {}

    func addFile(with url: URL) {
        let file = LocalFile(with: url)
        files[url] = file
    }

    func removeFile(with url: URL) {
        files[url] = nil
    }

    func files(for urls: [URL]) -> [LocalFile] {
        return urls.compactMap({ files[$0] })
    }
}

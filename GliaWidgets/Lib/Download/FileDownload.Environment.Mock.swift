extension FileDownload.Environment {
    static let mock = Self(fetchFile: { _, _, _ in })
}

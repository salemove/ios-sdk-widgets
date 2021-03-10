class FileSystemCache: Cache {
    func store(_ data: Data, for key: String) {

    }

    func url(for key: String) -> URL? {
        return nil
    }

    func data(for key: String) -> Data? {
        return nil
    }

    func hasData(for key: String) -> Bool {
        return false
    }
}

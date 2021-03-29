protocol DataStorage {
    func store(_ data: Data, for key: String)
    func store(from url: URL, for key: String)
    func url(for key: String) -> URL
    func data(for key: String) -> Data?
    func hasData(for key: String) -> Bool
    func removeData(for key: String)
}

protocol Cache {
    func store(_ data: Data, for key: String)
    func url(for key: String) -> URL?
    func data(for key: String) -> Data?
    func hasData(for key: String) -> Bool
}

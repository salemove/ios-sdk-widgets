protocol FileDownloadable {
    var id: String? { get }
    var name: String? { get }
    var isDeleted: Bool? { get }
    var isImage: Bool { get }
}

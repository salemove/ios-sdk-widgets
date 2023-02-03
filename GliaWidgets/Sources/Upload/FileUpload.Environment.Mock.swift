#if DEBUG
extension FileUpload.Environment {
    static let mock = Self(
        uploadFile: .mock,
        uuid: { .mock }
    )
}

extension FileUpload.Environment.UploadFile {
    static let mock = FileUploader.Environment.UploadFile.toConversation({ _, _, _ in .mock })
}
#endif

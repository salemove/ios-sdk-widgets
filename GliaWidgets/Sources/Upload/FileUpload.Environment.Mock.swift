#if DEBUG
extension FileUpload.Environment {
    static let mock = Self(
        uploadFile: .mock,
        uuid: { .mock }
    )
}

extension FileUpload.Environment.UploadFile {
    static let mock = FileUploader.Environment.UploadFile.toSecureMessaging { _, _ in
        try await Task.sleep(nanoseconds: UInt64.max)
        throw CancellationError()
    }
}
#endif

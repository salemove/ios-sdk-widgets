#if DEBUG
extension FileUpload.Environment {
    static let mock = Self(uploadFileToEngagement: { _, _, _ in })
}
#endif

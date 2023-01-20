#if DEBUG
extension FileUploader {
    static func mock(
        maximumUploads: Int = .zero,
        environment: Environment = .mock
    ) -> FileUploader {
        .init(
            maximumUploads: maximumUploads,
            environment: environment
        )
    }
}
#endif

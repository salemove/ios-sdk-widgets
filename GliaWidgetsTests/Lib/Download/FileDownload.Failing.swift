@testable import GliaWidgets

extension FileDownload {
    static let failing = FileDownload(
        with: .mock(),
        storage: FileSystemStorage.failing,
        environment: .failing
    )
}

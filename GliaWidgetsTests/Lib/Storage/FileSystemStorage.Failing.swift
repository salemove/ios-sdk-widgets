@testable import GliaWidgets

extension FileSystemStorage {
    static let failing = FileSystemStorage(
        directory: .documents(.failing),
        environment: .failing
    )
}

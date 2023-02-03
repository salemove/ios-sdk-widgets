@testable import GliaWidgets

extension FileUploader {
    static let failing = FileUploader(maximumUploads: .zero, environment: .failing)
}

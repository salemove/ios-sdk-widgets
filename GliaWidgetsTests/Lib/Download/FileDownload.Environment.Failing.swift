@testable import GliaWidgets

extension FileDownload.Environment {
    static let failing = Self(
        fetchFile: { _, _, _ in
            fail("\(Self.self).fetchFile")
        },
        fileManager: .failing,
        gcd: .failing,
        localFileThumbnailQueue: .failing,
        uiImage: .failing
    )
}

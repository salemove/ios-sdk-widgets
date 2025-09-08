@testable import GliaWidgets

extension FileDownload.Environment {
    static let failing = Self(
        fetchFile: { _, _ in
            fail("\(Self.self).fetchFile")
            throw NSError(domain: "fetchFile", code: -1)
        },
        downloadSecureFile: { _, _ in
            fail("\(Self.self).downloadSecureFile")
            throw NSError(domain: "downloadSecureFile", code: -1)
        },
        fileManager: .failing,
        gcd: .failing,
        uiScreen: .failing,
        createThumbnailGenerator: { .failing }
    )
}

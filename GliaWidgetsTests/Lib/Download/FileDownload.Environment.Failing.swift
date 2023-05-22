@testable import GliaWidgets

extension FileDownload.Environment {
    static let failing = Self(
        fetchFile: { _, _, _ in fail("\(Self.self).fetchFile") },
        downloadSecureFile: { _, _, _ in
            fail("\(Self.self).downloadSecureFile")
            return .mock
        },
        fileManager: .failing,
        gcd: .failing,
        uiScreen: .failing,
        createThumbnailGenerator: { .failing }
    )
}

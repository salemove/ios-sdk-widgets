@testable import GliaWidgets

extension ChatViewModel.Environment {
    static let failing = Self(
        chatStorage: .failing,
        fetchFile: { _, _, _ in
            fail("\(Self.self).fetchFile")
        },
        sendSelectedOptionValue: { _, _ in
            fail("\(Self.self).sendSelectedOptionValue")
        },
        uploadFileToEngagement: { _, _, _ in
            fail("\(Self.self).uploadFileToEngagement")
        },
        fileManager: .failing,
        data: .failing,
        date: {
            fail("\(Self.self).date")
            return .mock
        },
        gcd: .failing,
        localFileThumbnailQueue: .failing,
        uiImage: .failing,
        createFileDownload: { _, _, _ in
            fail("\(Self.self).createFileDownload")
            return .failing
        },
        fromHistory: {
            fail("\(Self.self).fromHistory")
            return true
        },
        fetchSiteConfigurations: { _ in
            fail("\(Self.self).fetchSiteConfigurations")
        }
    )
}

@testable import GliaWidgets

extension RootCoordinator.Environment {
    static let failing = Self.init(
        fetchFile: { _, _, _ in
            fail("\(Self.self).fetchFile")
        },
        sendSelectedOptionValue: { _, _ in
            fail("\(Self.self).sendSelectedOptionValue")
        },
        uploadFileToEngagement: { _, _, _ in
            fail("\(Self.self).uploadFileToEngagement")
        },
        audioSession: .failing,
        uuid: {
            fail("\(Self.self).uuid")
            return .mock
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
        createFileDownload: { _, _, _ in .failing },
        loadChatMessagesFromHistory: {
            fail("\(Self.self).loadChatMessagesFromHistory")
            return true
        },
        timerProviding: .failing,
        fetchSiteConfigurations: { _ in
            fail("\(Self.self).fetchSiteConfigurations")
        },
        getCurrentEngagement: {
            fail("\(Self.self).getCurrentEngagement")
            return nil
        },
        submitSurveyAnswer: { _, _, _, _ in
            fail("\(Self.self).submitSurveyAnswer")
        },
        uiApplication: .failing,
        fetchChatHistory: { _ in fail("\(Self.self).fetchChatHistory")},
        sendSecureMessage: { _, _, _, _ in
            fail("\(Self.self).sendScureMessage")
            return .init()
        },
        createFileUploader: { _, _ in
            .failing
        },
        createFileUploadListModel: { _ in
            fail("\(Self.self).createFileUploadListModel")
            return .mock()

        }
    )
}

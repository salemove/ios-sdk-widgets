import Foundation

extension SecureConversations.TranscriptModel {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var uiScreen: UIKitBased.UIScreen
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
        var createFileDownload: FileDownloader.CreateFileDownload
        var loadChatMessagesFromHistory: () -> Bool
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var uiApplication: UIKitBased.UIApplication
        var sendSecureMessagePayload: CoreSdkClient.SendSecureMessagePayload
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var uuid: () -> UUID
        var secureUploadFile: CoreSdkClient.SecureConversationsUploadFile
        var fileUploadListStyle: FileUploadListStyle
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getSecureUnreadMessageCount: CoreSdkClient.GetSecureUnreadMessageCount
        var messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.DateScheduler
        var secureMarkMessagesAsRead: CoreSdkClient.SecureMarkMessagesAsRead
        var interactor: Interactor
        var startSocketObservation: CoreSdkClient.StartSocketObservation
        var stopSocketObservation: CoreSdkClient.StopSocketObservation
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
        var log: CoreSdkClient.Logger
        var maximumUploads: () -> Int
    }
}

extension SecureConversations.TranscriptModel.Environment {
    static func create(
        with environment: ChatCoordinator.Environment,
        viewFactory: ViewFactory
    ) -> Self {
        .init(
            fetchFile: environment.fetchFile,
            downloadSecureFile: environment.downloadSecureFile,
            fileManager: environment.fileManager,
            data: environment.data,
            date: environment.date,
            gcd: environment.gcd,
            uiScreen: environment.uiScreen,
            createThumbnailGenerator: environment.createThumbnailGenerator,
            createFileDownload: environment.createFileDownload,
            loadChatMessagesFromHistory: environment.fromHistory,
            fetchChatHistory: environment.fetchChatHistory,
            uiApplication: environment.uiApplication,
            sendSecureMessagePayload: environment.sendSecureMessagePayload,
            queueIds: environment.queueIds,
            listQueues: environment.listQueues,
            createFileUploadListModel: environment.createFileUploadListModel,
            uuid: environment.uuid,
            secureUploadFile: environment.secureUploadFile,
            fileUploadListStyle: viewFactory.theme.chatStyle.messageEntry.uploadList,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            getSecureUnreadMessageCount: environment.getSecureUnreadMessageCount,
            messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
            secureMarkMessagesAsRead: environment.secureMarkMessagesAsRead,
            interactor: environment.interactor,
            startSocketObservation: environment.startSocketObservation,
            stopSocketObservation: environment.stopSocketObservation,
            createSendMessagePayload: environment.createSendMessagePayload,
            log: environment.log,
            maximumUploads: environment.maximumUploads
       )
    }
}

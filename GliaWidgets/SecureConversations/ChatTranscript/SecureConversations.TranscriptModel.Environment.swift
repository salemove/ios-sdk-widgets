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
        var shouldShowLeaveSecureConversationDialog: Bool
        var leaveCurrentSecureConversation: Cmd
        var createEntryWidget: EntryWidgetBuilder
        var switchToEngagement: Command<EngagementKind>
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
            // TODO: MOB-3763
            fileUploadListStyle: viewFactory.theme.chatStyle.messageEntry.enabled.uploadList,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            getSecureUnreadMessageCount: environment.getSecureUnreadMessageCount,
            messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
            secureMarkMessagesAsRead: environment.secureMarkMessagesAsRead,
            interactor: environment.interactor,
            startSocketObservation: environment.startSocketObservation,
            stopSocketObservation: environment.stopSocketObservation,
            createSendMessagePayload: environment.createSendMessagePayload,
            log: environment.log,
            maximumUploads: environment.maximumUploads,
            shouldShowLeaveSecureConversationDialog: environment.shouldShowLeaveSecureConversationDialog,
            leaveCurrentSecureConversation: environment.leaveCurrentSecureConversation,
            createEntryWidget: environment.createEntryWidget,
            switchToEngagement: environment.switchToEngagement
       )
    }
}

#if DEBUG
extension SecureConversations.TranscriptModel.Environment {
    static func mock(
        fetchFile: @escaping CoreSdkClient.FetchFile = { _, _, _ in },
        downloadSecureFile: @escaping CoreSdkClient.DownloadSecureFile = { _, _, _ in .mock },
        fileManager: FoundationBased.FileManager = .mock,
        data: FoundationBased.Data = .mock,
        date: @escaping () -> Date = { .mock },
        gcd: GCD = .mock,
        uiScreen: UIKitBased.UIScreen = .mock,
        createThumbnailGenerator: @escaping () -> QuickLookBased.ThumbnailGenerator = { .mock },
        createFileDownload: @escaping FileDownloader.CreateFileDownload = { _, _, _ in .mock() },
        loadChatMessagesFromHistory: @escaping () -> Bool = { false },
        fetchChatHistory: @escaping CoreSdkClient.FetchChatHistory = { _ in },
        uiApplication: UIKitBased.UIApplication = .mock,
        sendSecureMessagePayload: @escaping CoreSdkClient.SendSecureMessagePayload = { _, _, _ in .mock },
        queueIds: [String] = [],
        listQueues: @escaping CoreSdkClient.ListQueues = { _ in },
        createFileUploadListModel: @escaping SecureConversations.FileUploadListViewModel.Create = { _ in .mock() },
        uuid: @escaping () -> UUID = { .mock },
        secureUploadFile: @escaping CoreSdkClient.SecureConversationsUploadFile = { _, _, _ in .mock },
        fileUploadListStyle: FileUploadListStyle = .mock,
        fetchSiteConfigurations: @escaping CoreSdkClient.FetchSiteConfigurations = { _ in },
        getSecureUnreadMessageCount: @escaping CoreSdkClient.GetSecureUnreadMessageCount = { _ in },
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.DateScheduler = CoreSdkClient.ReactiveSwift.TestScheduler(),
        secureMarkMessagesAsRead: @escaping CoreSdkClient.SecureMarkMessagesAsRead = { _ in .mock },
        interactor: Interactor = .mock(),
        startSocketObservation: @escaping CoreSdkClient.StartSocketObservation = {},
        stopSocketObservation: @escaping CoreSdkClient.StopSocketObservation = {},
        createSendMessagePayload: @escaping CoreSdkClient.CreateSendMessagePayload = { _, _ in .mock() },
        log: CoreSdkClient.Logger = .mock,
        maximumUploads: @escaping () -> Int = { .zero },
        shouldShowLeaveSecureConversationDialog: Bool = false,
        leaveCurrentSecureConversation: Cmd = .nop,
        createEntryWidget: @escaping EntryWidgetBuilder = { _ in .mock() },
        switchToEngagement: Command<EngagementKind> = .nop
    ) -> Self {
        Self(
            fetchFile: fetchFile,
            downloadSecureFile: downloadSecureFile,
            fileManager: fileManager,
            data: data,
            date: date,
            gcd: gcd,
            uiScreen: uiScreen,
            createThumbnailGenerator: createThumbnailGenerator,
            createFileDownload: createFileDownload,
            loadChatMessagesFromHistory: loadChatMessagesFromHistory,
            fetchChatHistory: fetchChatHistory,
            uiApplication: uiApplication,
            sendSecureMessagePayload: sendSecureMessagePayload,
            queueIds: queueIds,
            listQueues: listQueues,
            createFileUploadListModel: createFileUploadListModel,
            uuid: uuid,
            secureUploadFile: secureUploadFile,
            fileUploadListStyle: fileUploadListStyle,
            fetchSiteConfigurations: fetchSiteConfigurations,
            getSecureUnreadMessageCount: getSecureUnreadMessageCount,
            messagesWithUnreadCountLoaderScheduler: messagesWithUnreadCountLoaderScheduler,
            secureMarkMessagesAsRead: secureMarkMessagesAsRead,
            interactor: interactor,
            startSocketObservation: startSocketObservation,
            stopSocketObservation: stopSocketObservation,
            createSendMessagePayload: createSendMessagePayload,
            log: log,
            maximumUploads: maximumUploads,
            shouldShowLeaveSecureConversationDialog: shouldShowLeaveSecureConversationDialog,
            leaveCurrentSecureConversation: leaveCurrentSecureConversation,
            createEntryWidget: createEntryWidget,
            switchToEngagement: switchToEngagement
        )
    }
}
#endif

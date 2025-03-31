import Foundation

extension SecureConversations.WelcomeViewModel {
    struct Environment {
        var secureConversations: CoreSdkClient.SecureConversations
        var welcomeStyle: SecureConversations.WelcomeStyle
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var fileUploader: FileUploader
        var uiApplication: UIKitBased.UIApplication
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var startSocketObservation: CoreSdkClient.StartSocketObservation
        var stopSocketObservation: CoreSdkClient.StopSocketObservation
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
        var log: CoreSdkClient.Logger
    }
}

extension SecureConversations.WelcomeViewModel.Environment {
    static func create(
        with environment: SecureConversations.Coordinator.Environment,
        viewFactory: ViewFactory
    ) -> Self {
        .init(
            secureConversations: environment.secureConversations,
            welcomeStyle: viewFactory.theme.secureConversationsWelcome,
            queueIds: environment.queueIds,
            listQueues: environment.listQueues,
            fileUploader: environment.createFileUploader(
                environment.maximumUploads(),
                .create(with: environment)
            ),
            uiApplication: environment.uiApplication,
            createFileUploadListModel: environment.createFileUploadListModel,
            fetchSiteConfigurations: environment.fetchSiteConfigurations,
            startSocketObservation: environment.startSocketObservation,
            stopSocketObservation: environment.stopSocketObservation,
            getCurrentEngagement: environment.getCurrentEngagement,
            uploadFileToEngagement: environment.uploadFileToEngagement,
            createSendMessagePayload: environment.createSendMessagePayload,
            log: environment.log
        )
    }
}

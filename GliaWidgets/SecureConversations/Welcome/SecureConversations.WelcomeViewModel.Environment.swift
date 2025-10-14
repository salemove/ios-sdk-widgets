import Foundation
import GliaCoreSDK

extension SecureConversations.WelcomeViewModel {
    struct Environment {
        var secureConversations: CoreSdkClient.SecureConversations
        var welcomeStyle: SecureConversations.WelcomeStyle
        var queueIds: [String]
        var listQueues: CoreSdkClient.GetQueues
        var fileUploader: FileUploader
        var uiApplication: UIKitBased.UIApplication
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
        var log: CoreSdkClient.Logger
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
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
            getCurrentEngagement: environment.getCurrentEngagement,
            uploadFileToEngagement: environment.uploadFileToEngagement,
            createSendMessagePayload: environment.createSendMessagePayload,
            log: environment.log
        )
    }
}

#if DEBUG
extension SecureConversations.WelcomeViewModel.Environment {
    static let mock = Self(
        secureConversations: .mock,
        welcomeStyle: Theme.mock().secureConversationsWelcomeStyle,
        queueIds: [],
        listQueues: { [.mock()] },
        fileUploader: .mock(),
        uiApplication: .mock,
        createFileUploadListModel: { _ in  .mock() },
        fetchSiteConfigurations: { try .mock() },
        getCurrentEngagement: { .mock() },
        uploadFileToEngagement: { _, _, _ in },
        createSendMessagePayload: { _, _ in .mock() },
        log: .mock
    )
}
#endif

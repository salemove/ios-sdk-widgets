import Foundation
@testable import GliaWidgets

extension SecureConversations.WelcomeViewModel {
    static let mock = SecureConversations.WelcomeViewModel(
        environment: .mock(),
        availability: .mock,
        delegate: nil
    )
}

extension SecureConversations.WelcomeViewModel.Environment {
    static func mock(
        welcomeStyle: SecureConversations.WelcomeStyle = Theme().secureConversationsWelcomeStyle,
        queueIds: [String] = [],
        listQueues: @escaping CoreSdkClient.ListQueues = { _ in },
        sendSecureMessagePayload: @escaping CoreSdkClient.SendSecureMessagePayload = { _, _, _ in return .mock },
        fileUploader: FileUploader = .mock(),
        uiApplication: UIKitBased.UIApplication = .mock,
        createFileUploadListModel: @escaping SecureConversations.FileUploadListViewModel.Create = { _ in .mock() },
        fetchSiteConfigurations: @escaping CoreSdkClient.FetchSiteConfigurations = { _ in },
        startSocketObservation: @escaping CoreSdkClient.StartSocketObservation = {},
        stopSocketObservation: @escaping CoreSdkClient.StopSocketObservation = {},
        getCurrentEngagement: @escaping CoreSdkClient.GetCurrentEngagement = { .mock() },
        uploadSecureFile: @escaping CoreSdkClient.SecureConversationsUploadFile = { _, _, _ in .mock },
        uploadFileToEngagement: @escaping CoreSdkClient.UploadFileToEngagement = { _, _, _ in },
        createSendMessagePayload: @escaping CoreSdkClient.CreateSendMessagePayload = { _, _ in .mock() },
        log: CoreSdkClient.Logger = .mock
    ) -> SecureConversations.WelcomeViewModel.Environment {
        .init(
            welcomeStyle: welcomeStyle,
            queueIds: queueIds,
            listQueues: listQueues,
            sendSecureMessagePayload: sendSecureMessagePayload,
            fileUploader: fileUploader,
            uiApplication: uiApplication,
            createFileUploadListModel: createFileUploadListModel,
            fetchSiteConfigurations: fetchSiteConfigurations,
            startSocketObservation: startSocketObservation,
            stopSocketObservation: stopSocketObservation,
            getCurrentEngagement: getCurrentEngagement,
            uploadSecureFile: uploadSecureFile,
            uploadFileToEngagement: uploadFileToEngagement,
            createSendMessagePayload: createSendMessagePayload,
            log: log
        )
    }
}

extension SecureConversations.Availability {
    static let mock: SecureConversations.Availability = .init(
        environment: .init(
            listQueues: { _ in },
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock()
        )
    )
}

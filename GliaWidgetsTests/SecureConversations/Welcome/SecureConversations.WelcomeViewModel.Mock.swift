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
        secureConversations: CoreSdkClient.SecureConversations = .mock,
        welcomeStyle: SecureConversations.WelcomeStyle = Theme().secureConversationsWelcomeStyle,
        queueIds: [String] = [],
        listQueues: @escaping CoreSdkClient.GetQueues = { _ in },
        fileUploader: FileUploader = .mock(),
        uiApplication: UIKitBased.UIApplication = .mock,
        createFileUploadListModel: @escaping SecureConversations.FileUploadListViewModel.Create = { _ in .mock() },
        fetchSiteConfigurations: @escaping CoreSdkClient.FetchSiteConfigurations = { _ in },
        startSocketObservation: @escaping CoreSdkClient.StartSocketObservation = {},
        stopSocketObservation: @escaping CoreSdkClient.StopSocketObservation = {},
        getCurrentEngagement: @escaping CoreSdkClient.GetCurrentEngagement = { .mock() },
        uploadFileToEngagement: @escaping CoreSdkClient.UploadFileToEngagement = { _, _, _ in },
        createSendMessagePayload: @escaping CoreSdkClient.CreateSendMessagePayload = { _, _ in .mock() },
        log: CoreSdkClient.Logger = .mock
    ) -> SecureConversations.WelcomeViewModel.Environment {
        .init(
            secureConversations: secureConversations,
            welcomeStyle: welcomeStyle,
            queueIds: queueIds,
            listQueues: listQueues,
            fileUploader: fileUploader,
            uiApplication: uiApplication,
            createFileUploadListModel: createFileUploadListModel,
            fetchSiteConfigurations: fetchSiteConfigurations,
            startSocketObservation: startSocketObservation,
            stopSocketObservation: stopSocketObservation,
            getCurrentEngagement: getCurrentEngagement,
            uploadFileToEngagement: uploadFileToEngagement,
            createSendMessagePayload: createSendMessagePayload,
            log: log
        )
    }
}

extension SecureConversations.Availability {
    static let mock: SecureConversations.Availability = .init(
        environment: .init(
            getQueues: { _ in },
            isAuthenticated: { true },
            log: .mock,
            queuesMonitor: .mock(),
            getCurrentEngagement: { .mock() }
        )
    )
}

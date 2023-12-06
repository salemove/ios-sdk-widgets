import Foundation
@testable import GliaWidgets

extension SecureConversations.WelcomeViewModel {
    static let mock = SecureConversations.WelcomeViewModel(
        environment: .mock,
        availability: .mock,
        delegate: nil
    )
}

extension SecureConversations.WelcomeViewModel.Environment {
    static let mock: SecureConversations.WelcomeViewModel.Environment = .init(
        welcomeStyle: Theme().secureConversationsWelcomeStyle,
        queueIds: [],
        listQueues: { _ in },
        sendSecureMessagePayload: { _, _, _ in return .mock },
        alertConfiguration: .mock(),
        fileUploader: .mock(),
        uiApplication: .mock,
        createFileUploadListModel: { _ in .mock() },
        fetchSiteConfigurations: { _ in },
        startSocketObservation: {},
        stopSocketObservation: {},
        getCurrentEngagement: { .mock() },
        uploadSecureFile: { _, _, _ in .mock },
        uploadFileToEngagement: { _, _, _ in },
        createSendMessagePayload: { _, _ in .mock() },
        log: .mock
    )
}

extension SecureConversations.Availability {
    static let mock: SecureConversations.Availability = .init(
        environment: .init(
            listQueues: { _ in },
            queueIds: [],
            isAuthenticated: { true }
        )
    )
}

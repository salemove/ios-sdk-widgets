import Foundation

extension SecureConversations.MessagesWithUnreadCountLoader {
    struct Environment {
        var getSecureUnreadMessageCount: CoreSdkClient.SecureConversations.GetUnreadMessageCount
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
    }
}

extension SecureConversations.MessagesWithUnreadCountLoader.Environment {
    static func create(with environment: SecureConversations.TranscriptModel.Environment) -> Self {
        .init(
            getSecureUnreadMessageCount: environment.secureConversations.getUnreadMessageCount,
            fetchChatHistory: environment.fetchChatHistory
        )
    }
}

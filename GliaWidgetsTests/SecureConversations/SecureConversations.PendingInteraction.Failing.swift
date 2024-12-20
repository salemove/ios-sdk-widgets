@testable import GliaWidgets

extension SecureConversations.PendingInteraction.Environment {
    static let failing = Self(
        observePendingSecureConversationsStatus: { _ in
            fail("\(Self.self).observePendingSecureConversationsStatus")
            return nil
        },
        observeSecureConversationsUnreadMessageCount: { _ in
            fail("\(Self.self).observeSecureConversationsUnreadMessageCount")
            return nil
        },
        unsubscribeFromUnreadCount: { _ in
            fail("\(Self.self).unsubscribeFromUnreadCount")
        },
        unsubscribeFromPendingStatus: { _ in
            fail("\(Self.self).unsubscribeFromPendingStatus")
        }
    )
}

extension SecureConversations.PendingInteraction {
    static func failing() throws -> Self {
        try .init(environment: .failing)
    }
}

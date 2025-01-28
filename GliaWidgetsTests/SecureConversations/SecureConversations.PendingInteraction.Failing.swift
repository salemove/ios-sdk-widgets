@testable import GliaWidgets
import Combine

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
        },
        // InteractorPublisher cannot call fail because it is a
        // computed property and will fail immediately upon
        // initialization, meaning that it fails before the override.
        // Instead we return a do-nothing publisher.
        interactorPublisher: Empty<Interactor?, Never>(completeImmediately: false)
            .eraseToAnyPublisher()
    )
}

extension SecureConversations.PendingInteraction {
    static func failing() throws -> Self {
        try .init(environment: .failing)
    }
}

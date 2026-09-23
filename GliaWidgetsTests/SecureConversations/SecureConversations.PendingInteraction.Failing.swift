@testable import GliaWidgets
import Combine

extension SecureConversations.PendingInteraction.Environment {
    static let failing = Self(
        pendingSecureConversationStatusStream: {
            fail("\(Self.self).pendingSecureConversationStatusStream")
            return AsyncThrowingStream { $0.finish() }
        },
        unreadMessageCountStream: {
            fail("\(Self.self).unreadMessageCountStream")
            return AsyncThrowingStream { $0.finish() }
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

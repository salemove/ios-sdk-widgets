@testable import GliaWidgets

extension AuthenticatedChatStorage {
    static let failing = Self(
        isEmpty: {
            fail("\(Self.self).isEmpty")
            return false
        },
        messages: { _ in
            fail("\(Self.self).messages")
            return []
        },
        updateMessage: { _ in
            fail("\(Self.self).updateMessage")
        },
        storeMessage: { _, _, _ in
            fail("\(Self.self).storeMessage")
        },
        storeMessages: { _, _, _ in
            fail("\(Self.self).storeMessages")
        },
        isNewMessage: { _ in
            fail("\(Self.self).isNewMessage")
            return false
        },
        newMessages: { _ in
            fail("\(Self.self).newMessages")
            return []
        },
        clear: {
            fail("\(Self.self).clear")
        }
    )
}

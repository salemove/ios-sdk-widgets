@testable import GliaWidgets

extension SecureConversations.Availability.Environment {
    static let failing = Self(
        listQueues: { _ in
            fail("\(Self.self).listQueues")
        },
        isAuthenticated: {
            fail("\(Self.self).isAuthenticated")
            return false
        },
        log: .failing,
        queuesMonitor: .failing,
        getCurrentEngagement: {
            fail("\(Self.self).getCurrentEngagement")
            return .mock()
        }
    )
}

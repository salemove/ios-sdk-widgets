import Foundation

extension EntryWidget {
    struct Environment {
        var queuesMonitor: QueuesMonitor
        var engagementLauncher: EngagementLauncher
        var theme: Theme
        var isAuthenticated: () -> Bool
    }
}

#if DEBUG
extension EntryWidget.Environment {
    static func mock() -> Self {
        let engagementLauncher = EngagementLauncher { _, _ in }
        let theme = Theme()
        return .init(
            queuesMonitor: .mock(),
            engagementLauncher: engagementLauncher,
            theme: theme,
            isAuthenticated: { true }
        )
    }
}
#endif

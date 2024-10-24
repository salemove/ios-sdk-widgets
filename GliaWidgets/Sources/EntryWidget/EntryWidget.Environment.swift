import Foundation

extension EntryWidget {
    struct Environment {
        var queuesMonitor: QueuesMonitor
        var engagementLauncher: EngagementLauncher
        var theme: Theme
        var isAuthenticated: () -> Bool
    }
}

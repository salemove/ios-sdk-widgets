import Foundation
import Combine

extension EntryWidget {
    struct Environment {
        var observeSecureUnreadMessageCount: CoreSdkClient.SubscribeForUnreadSCMessageCount
        var unsubscribeFromUpdates: CoreSdkClient.UnsubscribeFromUpdates
        var queuesMonitor: QueuesMonitor
        var engagementLauncher: EngagementLauncher
        var theme: Theme
        var log: CoreSdkClient.Logger
        var isAuthenticated: () -> Bool
        var hasPendingInteraction: () -> Bool
        var interactorPublisher: AnyPublisher<Interactor?, Never>
        var onCallVisualizerResume: () -> Void
    }
}

#if DEBUG
extension EntryWidget.Environment {
    static func mock() -> Self {
        let engagementLauncher = EngagementLauncher { _, _ in }
        return .init(
            observeSecureUnreadMessageCount: { _ in UUID.mock.uuidString },
            unsubscribeFromUpdates: { _, _ in },
            queuesMonitor: .mock(),
            engagementLauncher: engagementLauncher,
            theme: .mock(),
            log: .mock,
            isAuthenticated: { true },
            hasPendingInteraction: { false },
            interactorPublisher: Just(nil).eraseToAnyPublisher(),
            onCallVisualizerResume: {}
        )
    }
}
#endif

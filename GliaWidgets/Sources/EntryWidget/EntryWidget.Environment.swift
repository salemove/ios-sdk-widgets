import Foundation
import Combine
@_spi(GliaWidgets) import GliaCoreSDK

extension EntryWidget {
    struct Environment {
        var observeSecureUnreadMessageCount: CoreSdkClient.SecureConversations.SubscribeForUnreadMessageCount
        var queuesMonitor: QueuesMonitor
        var engagementLauncher: EngagementLauncher
        var theme: Theme
        var log: CoreSdkClient.Logger
        var isAuthenticated: () -> Bool
        var hasPendingInteractionPublisher: AnyPublisher<Bool, Never>
        var interactorPublisher: AnyPublisher<Interactor?, Never>
        var onCallVisualizerResume: () -> Void
        var combineScheduler: CoreSdkClient.AnyCombineScheduler
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

#if DEBUG
extension EntryWidget.Environment {
    static func mock() -> Self {
        let engagementLauncher = EngagementLauncher { _, _ in }
        return .init(
            observeSecureUnreadMessageCount: { AsyncThrowingStream { $0.finish() } },
            queuesMonitor: .mock(),
            engagementLauncher: engagementLauncher,
            theme: .mock(),
            log: .mock,
            isAuthenticated: { true },
            hasPendingInteractionPublisher: .mock(false),
            interactorPublisher: .mock(nil),
            onCallVisualizerResume: {},
            combineScheduler: .mock
        )
    }
}
#endif

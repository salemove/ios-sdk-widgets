import Foundation

#if DEBUG

extension OrientationManager {
    static func mock(
        uiApplication: UIKitBased.UIApplication = .mock,
        uiDevice: UIKitBased.UIDevice = .mock,
        notificationCenter: FoundationBased.NotificationCenter = .mock
    ) -> OrientationManager {
        .init(environment: .init(
            uiApplication: uiApplication,
            uiDevice: uiDevice,
            notificationCenter: notificationCenter
        ))
    }
}

#endif

import Foundation
import GliaCoreSDK

extension SecureConversations.ConfirmationViewSwiftUI.Model {
    struct Environment {
        var orientationManager: OrientationManager
        var uiApplication: UIKitBased.UIApplication
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}

extension SecureConversations.ConfirmationViewSwiftUI.Model.Environment {
    static func create(with environment: SecureConversations.Coordinator.Environment) -> Self {
        .init(
            orientationManager: environment.orientationManager,
            uiApplication: environment.uiApplication
        )
    }
}

#if DEBUG
extension SecureConversations.ConfirmationViewSwiftUI.Model.Environment {
    static func mock(
        orientationManager: OrientationManager = .mock(),
        uiApplication: UIKitBased.UIApplication = .mock
    ) -> Self {
        .init(
            orientationManager: orientationManager,
            uiApplication: uiApplication
        )
    }
}
#endif

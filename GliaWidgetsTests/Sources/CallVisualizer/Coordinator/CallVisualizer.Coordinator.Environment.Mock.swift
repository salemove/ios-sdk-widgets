import Foundation
@testable import GliaWidgets

extension CallVisualizer.Coordinator.Environment {
    static let mock: Self = .init(
        data: .mock,
        uuid: { .mock },
        gcd: .mock,
        imageViewCache: .mock,
        uiApplication: .mock,
        uiScreen: .mock,
        uiDevice: .mock,
        notificationCenter: .mock,
        viewFactory: .mock(),
        presenter: .topViewController(application: .mock),
        bundleManaging: .live,
        screenShareHandler: .mock,
        timerProviding: .mock,
        requestVisitorCode: { completion in .mock },
        audioSession: .mock,
        date: { .mock },
        engagedOperator: { .mock() },
        eventHandler: { event in },
        orientationManager: .mock(),
        proximityManager: .mock,
        log: .mock,
        fetchSiteConfigurations: { completion in },
        snackBar: .mock,
        cameraDeviceManager: { .mock }
    )
}

import Foundation
@testable import GliaWidgets

extension CallVisualizer.VideoCallCoordinator.Environment {
    static let mock = Self(
        data: .mock,
        uuid: { .mock },
        gcd: .mock,
        imageViewCache: .mock,
        timerProviding: .mock,
        uiApplication: .mock,
        uiScreen: .mock,
        uiDevice: .mock,
        notificationCenter: .mock,
        date: { .mock },
        engagedOperator: { .mock() },
        screenShareHandler: .mock,
        proximityManager: .mock,
        log: .mock
    )
}

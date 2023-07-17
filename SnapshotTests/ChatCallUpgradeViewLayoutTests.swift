@testable import GliaWidgets
import SnapshotTesting
import XCTest

class ChatCallUpgradeViewLayoutTests: SnapshotTestCase {
    func test_chatCallUpgradeViewToAudio() {
        let upgradeView = ChatCallUpgradeView(with: Theme.mock().chat.audioUpgrade, duration: .init(with: .zero))
        upgradeView.frame = .init(origin: .zero, size: .init(width: 300, height: 120))
        assertSnapshot(
            matching: upgradeView,
            as: .image
        )
    }

    func test_chatCallUpgradeViewToVideo() {
        let upgradeView = ChatCallUpgradeView(with: Theme.mock().chat.videoUpgrade, duration: .init(with: .zero))
        upgradeView.frame = .init(origin: .zero, size: .init(width: 300, height: 120))
        assertSnapshot(
            matching: upgradeView,
            as: .image
        )
    }
}

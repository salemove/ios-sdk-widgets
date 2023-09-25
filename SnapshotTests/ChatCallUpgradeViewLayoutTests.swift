@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class ChatCallUpgradeViewLayoutTests: SnapshotTestCase {
    func test_chatCallUpgradeViewToAudio() {
        let upgradeView = ChatCallUpgradeView(with: Theme.mock().chat.audioUpgrade, duration: .init(with: .zero))
        upgradeView.frame = .init(origin: .zero, size: .init(width: 300, height: 120))
        upgradeView.assertSnapshot(as: .image, in: .portrait)
        upgradeView.assertSnapshot(as: .image, in: .landscape)
    }

    func test_chatCallUpgradeViewToVideo() {
        let upgradeView = ChatCallUpgradeView(with: Theme.mock().chat.videoUpgrade, duration: .init(with: .zero))
        upgradeView.frame = .init(origin: .zero, size: .init(width: 300, height: 120))
        upgradeView.assertSnapshot(as: .image, in: .portrait)
        upgradeView.assertSnapshot(as: .image, in: .landscape)
    }
}

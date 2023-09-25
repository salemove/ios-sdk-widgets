@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class ChatCallUpgradeViewDynamicTypeFontTests: SnapshotTestCase {
    func test_chatCallUpgradeViewToAudio_extra3Large() {
        let upgradeView = ChatCallUpgradeView(with: Theme.mock().chat.audioUpgrade, duration: .init(with: .zero))
        upgradeView.frame = .init(origin: .zero, size: .init(width: 300, height: 160))
        upgradeView.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        upgradeView.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_chatCallUpgradeViewToVideo_extra3Large() {
        let upgradeView = ChatCallUpgradeView(with: Theme.mock().chat.videoUpgrade, duration: .init(with: .zero))
        upgradeView.frame = .init(origin: .zero, size: .init(width: 300, height: 160))
        upgradeView.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        upgradeView.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}

@testable import GliaWidgets
import XCTest
import SnapshotTesting

final class ThemeRemoteConfigurationTests: SnapshotTestCase {
    func test_themeForMessagesFromHistory() throws {
        let url = try XCTUnwrap(
            Bundle(for: Self.self)
                .url(
                    forResource: "unified_sample.json",
                    withExtension: nil
                )
        )

        let jsonData = try Data(contentsOf: url)
        let config = try JSONDecoder().decode(
            RemoteConfiguration.self,
            from: .init(jsonData)
        )

        let theme = Theme(
            uiConfig: config,
            assetsBuilder: .standard
        )

        let viewController = ChatViewController.mockHistoryMessagesScreen(theme: theme)
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(
            matching: viewController,
            as: .image,
            named: nameForDevice()
        )
    }
}

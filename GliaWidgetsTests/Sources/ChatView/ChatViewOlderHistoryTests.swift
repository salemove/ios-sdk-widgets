import XCTest
@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

final class ChatViewOlderHistoryTests: XCTestCase {
    func test_themeDefaultsOlderMessagesIndicatorColorToPrimary() {
        let theme = Theme()

        XCTAssertEqual(theme.chat.olderMessagesIndicatorColor, theme.color.primary)
    }

    func test_remoteConfigurationOverridesOlderMessagesIndicatorColor() throws {
        let json = Data(##"{"olderMessagesIndicator": {"type": "fill", "value": ["#7c19dd"]}}"##.utf8)
        let configuration = try JSONDecoder().decode(RemoteConfiguration.Chat.self, from: json)
        let style = Theme().chat

        style.apply(configuration: configuration, assetsBuilder: .standard)

        XCTAssertEqual(style.olderMessagesIndicatorColor, UIColor(hex: "#7c19dd"))
    }

    func test_remoteConfigurationWithoutOlderMessagesIndicatorKeepsDefault() throws {
        let configuration = try JSONDecoder().decode(RemoteConfiguration.Chat.self, from: Data("{}".utf8))
        let theme = Theme()
        let style = theme.chat

        style.apply(configuration: configuration, assetsBuilder: .standard)

        XCTAssertEqual(style.olderMessagesIndicatorColor, theme.color.primary)
    }

    func test_refreshControlUsesStyleColor() {
        let style = Theme().chat
        style.olderMessagesIndicatorColor = UIColor(hex: "#7c19dd")

        let view = makeView(style: style)

        XCTAssertEqual(view.olderHistoryRefreshControl.tintColor, UIColor(hex: "#7c19dd"))
    }

    func test_refreshControlIsAttachedOnlyWhileOlderHistoryIsAvailable() {
        let view = makeView()
        XCTAssertNil(view.tableView.refreshControl)

        view.setOlderHistoryState(canLoad: true, isLoading: false)
        XCTAssertTrue(view.tableView.refreshControl === view.olderHistoryRefreshControl)

        view.setOlderHistoryState(canLoad: true, isLoading: true)
        XCTAssertTrue(view.tableView.refreshControl === view.olderHistoryRefreshControl)

        view.setOlderHistoryState(canLoad: false, isLoading: false)
        XCTAssertNil(view.tableView.refreshControl)
    }

    func test_pullingRefreshControlRequestsOlderHistory() {
        let view = makeView()
        var requests = 0
        view.loadOlderHistoryRequested = { requests += 1 }
        view.setOlderHistoryState(canLoad: true, isLoading: false)

        view.olderHistoryRefreshControl.sendActions(for: .valueChanged)

        XCTAssertEqual(requests, 1)
    }

    private func makeView(style: ChatStyle = .mock()) -> ChatView {
        let env = EngagementView.Environment(
            data: .failing,
            uuid: { .mock },
            gcd: .failing,
            imageViewCache: .failing,
            timerProviding: .failing,
            uiApplication: .failing,
            uiScreen: .failing,
            combineScheduler: .mock
        )
        return ChatView(
            with: style,
            messageRenderer: .webRenderer,
            environment: env,
            props: .init(header: .mock())
        )
    }
}

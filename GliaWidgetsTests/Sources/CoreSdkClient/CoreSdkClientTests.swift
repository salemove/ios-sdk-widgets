@_spi(GliaWidgets) internal import GliaCoreSDK
import XCTest
@testable import GliaWidgets

final class CoreSdkClientTests: XCTestCase {
    func testWidgetPushNotificationTypesMapToCoreTypes() {
        let mappings: [(GliaWidgets.PushNotificationsType, GliaCoreSDK.PushNotificationsType)] = [
            (.start, .start),
            (.end, .end),
            (.failed, .failed),
            (.message, .message),
            (.transfer, .transfer)
        ]

        mappings.forEach { widgetType, coreType in
            XCTAssertEqual(widgetType.coreType, coreType)
        }
    }

    func testCorePushMapsToWidgetPush() throws {
        let data = Data(
            #"{"actionIdentifier":"open","type":"queued_message.created","timing":1,"visitorId":"visitor-id"}"#.utf8
        )
        let corePush = try JSONDecoder().decode(GliaCoreSDK.Push.self, from: data)

        let push = GliaWidgets.Push(corePush: corePush)

        XCTAssertEqual(push.actionIdentifier, "open")
        XCTAssertEqual(push.type, .queueMessage)
        XCTAssertEqual(push.timing, .background)
        XCTAssertEqual(push.visitorId, "visitor-id")
    }

    func testCorePushWithUnknownValuesMapsToWidgetPush() throws {
        let data = Data(
            #"{"actionIdentifier":"custom","type":"custom-type","timing":99}"#.utf8
        )
        let corePush = try JSONDecoder().decode(GliaCoreSDK.Push.self, from: data)

        let push = GliaWidgets.Push(corePush: corePush)

        XCTAssertEqual(push.type, .unidentified("custom-type"))
        XCTAssertEqual(push.timing, .unidentified)
        XCTAssertNil(push.visitorId)
    }

    func testWidgetPushWithUnknownTimingDecodesAsUnidentified() throws {
        let data = Data(
            #"{"actionIdentifier":"custom","type":"custom-type","timing":99}"#.utf8
        )

        let push = try JSONDecoder().decode(GliaWidgets.Push.self, from: data)

        XCTAssertEqual(push.timing, .unidentified)
    }

    func testWidgetPushEqualityMatchesCorePushEquality() {
        let first = GliaWidgets.Push(
            actionIdentifier: "open",
            type: .queueMessage,
            timing: .inApp,
            visitorId: "first-visitor"
        )
        let second = GliaWidgets.Push(
            actionIdentifier: "open",
            type: .queueMessage,
            timing: .background,
            visitorId: "second-visitor"
        )

        XCTAssertEqual(first, second)
    }

    func testGetNonTransferredSecureConversationEngagementReturnsEngagement() {
        var client = CoreSdkClient.failing
        let engagement = CoreSdkClient.Engagement.mock(status: .engaged, capabilities: .init(text: false))
        client.getCurrentEngagement = { engagement }

        XCTAssertEqual(engagement, client.getNonTransferredSecureConversationEngagement())
    }

    func testGetNonTransferredSecureConversationEngagementReturnsNil() {
        var client = CoreSdkClient.failing
        let engagement = CoreSdkClient.Engagement.mock(status: .transferring, capabilities: .init(text: true))
        client.getCurrentEngagement = { engagement }

        XCTAssertNil(client.getNonTransferredSecureConversationEngagement())
    }
}

import XCTest
@testable import GliaWidgets

final class CoreSdkClientTests: XCTestCase {
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
